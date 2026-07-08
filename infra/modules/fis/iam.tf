resource "aws_iam_role" "fis_role" {
  name                 = "${var.project}-${var.environment}-fis-role"
  permissions_boundary = var.permissions_boundary_arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "fis.amazonaws.com" }
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "fis_policy" {
  name = "${var.project}-${var.environment}-fis-policy"
  role = aws_iam_role.fis_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "eks:DescribeCluster",
        "eks:ListClusters",
        "eks:DescribeNodegroup",
        "eks:AccessKubernetesApi",
        "aws-marketplace:ViewSubscriptions"
      ]
      Resource = "*"
    }]
  })
}
