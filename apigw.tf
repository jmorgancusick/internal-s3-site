resource "aws_api_gateway_rest_api" "internal_s3_site" {
  name = "internal-s3-site"
}

resource "aws_api_gateway_resource" "object" {
  rest_api_id = aws_api_gateway_rest_api.internal_s3_site.id
  parent_id   = aws_api_gateway_rest_api.internal_s3_site.root_resource_id
  path_part   = "{object+}"
}

resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.internal_s3_site.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_method.get,
      aws_api_gateway_integration.get,
      aws_api_gateway_integration_response.get_200,
      aws_api_gateway_method_response.get_200,
      aws_api_gateway_method.options,
      aws_api_gateway_integration.options,
      aws_api_gateway_integration_response.options_200,
      aws_api_gateway_method_response.options_200,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "dev" {
  rest_api_id   = aws_api_gateway_rest_api.internal_s3_site.id
  deployment_id = aws_api_gateway_deployment.example.id
  stage_name    = "dev"
}


# TODO: add logging https://stackoverflow.com/a/59057471
# resource "aws_api_gateway_method_settings" "dev" {
#   rest_api_id = aws_api_gateway_rest_api.internal_s3_site.id
#   stage_name  = aws_api_gateway_stage.dev.stage_name
#   method_path = "*/*"

#   settings {
#     metrics_enabled = true
#     logging_level   = "INFO"
#   }
# }

# ==========================================
# =============== GET for S3 ===============
# ==========================================

resource "aws_api_gateway_method" "get" {
  rest_api_id   = aws_api_gateway_rest_api.internal_s3_site.id
  resource_id   = aws_api_gateway_resource.object.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.object" = true
  }
}

resource "aws_api_gateway_integration" "get" {
  rest_api_id = aws_api_gateway_rest_api.internal_s3_site.id
  resource_id = aws_api_gateway_resource.object.id
  http_method = aws_api_gateway_method.get.http_method
  type        = "AWS"

  integration_http_method = "GET"

  uri         = "arn:aws:apigateway:${var.aws_region}:s3:path/${aws_s3_bucket.example.id}/{object}"
  credentials = aws_iam_role.apigw_exec.arn

  request_parameters = {
    "integration.request.path.object" = "method.request.path.object"
  }
}

resource "aws_api_gateway_integration_response" "get_200" {
  rest_api_id = aws_api_gateway_rest_api.internal_s3_site.id
  resource_id = aws_api_gateway_resource.object.id
  http_method = aws_api_gateway_method.get.http_method
  status_code = aws_api_gateway_method_response.get_200.status_code

  response_templates = {
    "application/json" = ""
  }

  response_parameters = {
    "method.response.header.Content-Type" = "integration.response.header.Content-Type"
  }
}

resource "aws_api_gateway_method_response" "get_200" {
  rest_api_id = aws_api_gateway_rest_api.internal_s3_site.id
  resource_id = aws_api_gateway_resource.object.id
  http_method = aws_api_gateway_method.get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Content-Type" = false
  }
}

# ==========================================
# ============ OPTIONS for CORS ============
# ==========================================

resource "aws_api_gateway_method" "options" {
  rest_api_id   = aws_api_gateway_rest_api.internal_s3_site.id
  resource_id   = aws_api_gateway_resource.object.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options" {
  rest_api_id = aws_api_gateway_rest_api.internal_s3_site.id
  resource_id = aws_api_gateway_resource.object.id
  http_method = aws_api_gateway_method.options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_integration_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.internal_s3_site.id
  resource_id = aws_api_gateway_resource.object.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = aws_api_gateway_method_response.options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.internal_s3_site.id
  resource_id = aws_api_gateway_resource.object.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false
    "method.response.header.Access-Control-Allow-Methods" = false
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
}
