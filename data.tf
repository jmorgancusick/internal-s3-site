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

# TODO: split admins, users and apigw role (only allow get)
data "aws_iam_policy_document" "this_accounts_admins" {
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
}

data "aws_secretsmanager_secret_version" "google_client_secret_current" {
  secret_id = aws_secretsmanager_secret_version.google_client_secret_current_initial.secret_id
}
