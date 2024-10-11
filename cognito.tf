# resource "aws_cognito_user_pool" "pool" {
#   name                     = "tf-serverlessrepo-cloudfront-authorization-at-edge"
#   auto_verified_attributes = ["email"]
# }

# resource "aws_cognito_identity_provider" "google_provider" {
#   user_pool_id  = aws_cognito_user_pool.pool.id
#   provider_name = "Google"
#   provider_type = "Google"

#   provider_details = {
#     authorize_scopes = "email"
#     client_id        = jsondecode(data.aws_secretsmanager_secret_version.google_client_secret_current.secret_string)["client_id"]
#     client_secret    = jsondecode(data.aws_secretsmanager_secret_version.google_client_secret_current.secret_string)["client_secret"]
#   }

#   attribute_mapping = {
#     email    = "email"
#     username = "sub"
#   }
# }
