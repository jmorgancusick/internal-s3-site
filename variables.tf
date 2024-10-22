variable "aws_profile" {
  description = "The profile to use when configuring the AWS provider"
  type        = string
  default     = "personal"
}

variable "aws_region" {
  description = "The region to use when configuring the AWS provider"
  type        = string
  default     = "us-east-1"
}

variable "owner" {
  description = "This project's owner, which will be added as a tag to resources"
  type        = string
  default     = "Jack Cusick"
}

variable "bucket_name" {
  description = "The bucket name that will host the origin static site"
  type        = string
  default     = "jmorgancusick-internal-s3-site"
}

variable "admin_iam_role_regex" {
  description = "A regex to match IAM roles that will have r/w permission on the s3 bucket"
  type        = string
  default     = "(AWSReservedSSO_AWSAdministratorAccess_|github_actions_admin).*"
}

variable "jumphost_name" {
  description = "The name of EC2 instance jumphost and associated resources"
  type        = string
  default     = "jumphost-deb-arm"
}

variable "proxy_port" {
  description = "The name port to run proxied https traffic through"
  type        = number
  default     = 8888
}

variable "proxy_username" {
  description = "The username for proxy basic auth"
  type        = string
  default     = "jack"
}
