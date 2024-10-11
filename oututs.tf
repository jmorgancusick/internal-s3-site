output "internal_s3_site_dev_url" {
  value       = "${aws_api_gateway_stage.dev.invoke_url}/index.html"
  description = "The dev URL of the created API GW"
}
