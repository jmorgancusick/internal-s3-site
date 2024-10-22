data "aws_iam_roles" "admins" {
  name_regex = var.admin_iam_role_regex
}

data "aws_iam_policy_document" "apigw_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

# AWS Managed
data "aws_iam_policy" "apigw_push_to_cloudwatch" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# AWS Managed
data "aws_iam_policy" "s3_read_only" {
  arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

data "aws_iam_policy_document" "internal_s3_site_bucket_policy" {
  statement {
    sid = "ThisAccountsAdmins"

    principals {
      type        = "AWS"
      identifiers = data.aws_iam_roles.admins.arns
    }

    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      aws_s3_bucket.example.arn,
      "${aws_s3_bucket.example.arn}/*",
    ]
  }

  statement {
    sid = "ApiGw"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.apigw_exec.arn]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      aws_s3_bucket.example.arn,
      "${aws_s3_bucket.example.arn}/*",
    ]
  }
}

data "aws_secretsmanager_secret_version" "google_client_secret_current" {
  secret_id = aws_secretsmanager_secret_version.google_client_secret_current_initial.secret_id
}

# Note: EC2 Instance Connect is pre-installed on Ubuntu 20.04 or later AMIs - https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-set-up.html
data "aws_ami" "ubuntu_arm" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_iam_policy_document" "apigw_vpce" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "execute-api:Invoke",
    ]

    resources = [
      "${aws_api_gateway_rest_api.internal_s3_site.execution_arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "apigw_allow_vpce_only" {
  statement {
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["execute-api:Invoke"]
    resources = ["${aws_api_gateway_rest_api.internal_s3_site.execution_arn}/*"]
  }
  statement {
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["execute-api:Invoke"]
    resources = ["${aws_api_gateway_rest_api.internal_s3_site.execution_arn}/*"]

    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpce"
      values   = [aws_vpc_endpoint.apigw.id]
    }
  }
}

# APIGW Logging - one time setup
data "aws_iam_policy_document" "apigw_logger_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}
