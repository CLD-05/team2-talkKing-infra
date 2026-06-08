variable "create_alias_record" {
  description = "Whether to create the Route53 alias record."
  type        = bool
  default     = false
}

variable "zone_name" {
  description = "Route53 hosted zone name."
  type        = string
  default     = ""
}

variable "private_zone" {
  description = "Whether the hosted zone is private."
  type        = bool
  default     = false
}

variable "record_name" {
  description = "DNS record name."
  type        = string
  default     = ""
}

variable "alias_dns_name" {
  description = "Alias target DNS name."
  type        = string
  default     = ""
}

variable "alias_zone_id" {
  description = "Alias target hosted zone ID."
  type        = string
  default     = ""
}
