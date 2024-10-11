resource "aws_iam_role" "apigw_exec" {
  name               = "internals3apigatewayrole"
  assume_role_policy = data.aws_iam_policy_document.apigw_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "apigw_exec_cloudwatch" {
  role       = aws_iam_role.apigw_exec.name
  policy_arn = data.aws_iam_policy.apigw_push_to_cloudwatch.arn
}

resource "aws_iam_role_policy_attachment" "apigw_exec_s3" {
  role       = aws_iam_role.apigw_exec.name
  policy_arn = data.aws_iam_policy.s3_read_only.arn
}
