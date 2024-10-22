resource "aws_iam_role" "apigw_exec" {
  name               = "internals3apigatewayrole"
  assume_role_policy = data.aws_iam_policy_document.apigw_assume_role_policy.json
}

# TODO - idt I need this
resource "aws_iam_role_policy_attachment" "apigw_exec_cloudwatch" {
  role       = aws_iam_role.apigw_exec.name
  policy_arn = data.aws_iam_policy.apigw_push_to_cloudwatch.arn
}

resource "aws_iam_role_policy_attachment" "apigw_exec_s3" {
  role       = aws_iam_role.apigw_exec.name
  policy_arn = data.aws_iam_policy.s3_read_only.arn
}

# APIGW Logging - one time setup
resource "aws_iam_role" "apigw_logger" {
  name               = "ApigwLogger"
  description        = "Allows API Gateway to push logs to CloudWatch Logs."
  assume_role_policy = data.aws_iam_policy_document.apigw_logger_assume_role_policy.json
}

# APIGW Logging - one time setup
resource "aws_iam_role_policy_attachment" "apigw_logger_cloudwatch" {
  role       = aws_iam_role.apigw_logger.name
  policy_arn = data.aws_iam_policy.apigw_push_to_cloudwatch.arn
}
