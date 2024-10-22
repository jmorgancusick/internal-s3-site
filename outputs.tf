output "internal_s3_site_dev_url" {
  value       = "${aws_api_gateway_stage.dev.invoke_url}/index.html"
  description = "The dev URL of the created API GW"
}

output "proxy_credentials_secret_name" {
  value       = aws_secretsmanager_secret.proxy_credentials.name
  description = "The AWS Secrets Manager name that is storing the proxy credentials"
}
