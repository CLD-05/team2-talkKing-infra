locals {
  common_tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

resource "aws_security_group" "this" {
  name        = "${var.project}-${var.environment}-bastion-sg"
  description = "Bastion security group."
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-bastion-sg"
  })
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ssh_cidrs
  security_group_id = aws_security_group.this.id
  description       = "SSH access to bastion."
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
  description       = "Allow all outbound traffic."
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_iam_role" "this" {
  name                 = "${var.project}-${var.environment}-bastion-role"
  permissions_boundary = var.permissions_boundary_arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "eks_read" {
  name = "${var.project}-${var.environment}-bastion-eks-read"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "eks:DescribeCluster",
        "eks:ListClusters",
        "eks:DescribeNodegroup",
        "eks:ListNodegroups"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.project}-${var.environment}-bastion-profile"
  role = aws_iam_role.this.name
}

resource "aws_launch_template" "this" {
  name          = "${var.project}-${var.environment}-bastion-lt"
  image_id      = var.ami_id != null ? var.ami_id : data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -euo pipefail
    dnf update -y
    dnf install -y unzip jq tar gzip

    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
    unzip -q /tmp/awscliv2.zip -d /tmp
    /tmp/aws/install --update

    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm -f kubectl /tmp/awscliv2.zip
    rm -rf /tmp/aws
  EOF
  )

  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.this.id]
    subnet_id                   = var.public_subnet_id
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = true
      encrypted             = true
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.common_tags, {
      Name = "${var.project}-${var.environment}-bastion"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(local.common_tags, {
      Name = "${var.project}-${var.environment}-bastion-root"
    })
  }

  tag_specifications {
    resource_type = "network-interface"
    tags = merge(local.common_tags, {
      Name = "${var.project}-${var.environment}-bastion-eni"
    })
  }

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-bastion-lt"
  })
}

resource "aws_instance" "this" {
  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-bastion"
  })

  volume_tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-bastion-root"
  })
}
# ==========================================================================
# AWS FIS(Fault Injection Service) 장애 주입용 IAM 및 인증 리소스 추가
# ==========================================================================

# 1. 대상 EKS 클러스터 정보 참조 (OIDC 발급자 주소를 가져오기 위함)
# 만약 이미 다른 파일에 선언되어 있다면 data 블록은 제외하셔도 됩니다.
data "aws_eks_cluster" "target" {
  name = "team2-talkking-dev-cluster" # 본인의 EKS 클러스터 이름 변수가 있다면 var.eks_cluster_name 등으로 대체 가능합니다.
}

# 2. OIDC Provider 고유 ID 파싱 및 ARN 구성
locals {
  oidc_url = replace(data.aws_eks_cluster.target.identity[0].oidc[0].issuer, "https://", "")
  oidc_arn = "arn:aws:iam::495599735720:oidc-provider/${local.oidc_url}"
}

# 3. AWS FIS 신뢰 관계 정책 (Trust Relationship) 정의
# (FIS 서비스 자체와 EKS OIDC 봇 양쪽 모두가 AssumeRole 할 수 있도록 허용)
data "aws_iam_policy_document" "fis_trust" {
  # [조항 1] AWS FIS 서비스 허용
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["fis.amazonaws.com"]
    }
  }

  # [조항 2] EKS OIDC 및 특정 서비스 어카운트 허용 (IRSA 연동용 웹 자격 증명)
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_url}:sub"
      values   = ["system:serviceaccount:talkking-dev:fis-experiment"]
    }
  }
}

# 4. IAM 역할 생성 (기존 파일의 네이밍/태그 규칙 동기화)
resource "aws_iam_role" "fis" {
  name               = "${var.project}-${var.environment}-fis-role"
  assume_role_policy = data.aws_iam_policy_document.fis_trust.json

  tags = local.common_tags
}

# 5. FIS 역할이 EKS 리소스를 제어할 수 있도록 추가 권한 인라인 정책 바인딩
# (필요에 따라 테라폼으로 완전히 관리하기 위해 추가해두면 좋습니다)
resource "aws_iam_role_policy" "fis_eks_access" {
  name = "${var.project}-${var.environment}-fis-eks-policy"
  role = aws_iam_role.this.id # 배스천 호스트나 혹은 아래 fis 역할에 필요한 권한에 맞춰 바인딩 가능합니다.

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "eks:DescribeCluster",
        "fis:InjectFault" # FIS 주입 권한 등 필요한 액션 정의
      ]
      Resource = "*"
    }]
  })
}
