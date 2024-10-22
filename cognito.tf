resource "aws_cognito_user_pool" "pool" {
  name                     = "internal-s3-site"
  auto_verified_attributes = ["email"]
}

resource "aws_cognito_identity_provider" "google_provider" {
  user_pool_id  = aws_cognito_user_pool.pool.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    authorize_scopes = "email"
    client_id        = jsondecode(data.aws_secretsmanager_secret_version.google_client_secret_current.secret_string)["client_id"]
    client_secret    = jsondecode(data.aws_secretsmanager_secret_version.google_client_secret_current.secret_string)["client_secret"]

    attributes_url                = "https://people.googleapis.com/v1/people/me?personFields="
    attributes_url_add_attributes = "true"
    authorize_url                 = "https://accounts.google.com/o/oauth2/v2/auth"
    oidc_issuer                   = "https://accounts.google.com"
    token_request_method          = "POST"
    token_url                     = "https://www.googleapis.com/oauth2/v4/token"
  }

  attribute_mapping = {
    email    = "email"
    username = "sub"
  }
}

resource "aws_cognito_user_pool_domain" "main" {
  user_pool_id = aws_cognito_user_pool.pool.id
  domain       = "jmorgancusick-internal-s3-site"
}

resource "aws_cognito_resource_server" "resource" {
  user_pool_id = aws_cognito_user_pool.pool.id
  identifier   = "https://internal-s3-site-1"
  name         = "internal-s3-site-1"

  scope {
    scope_name        = "full"
    scope_description = "full access to the site"
  }
}

resource "aws_cognito_user_pool_client" "client" {
  user_pool_id = aws_cognito_user_pool.pool.id

  name = "test app client"

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]

  callback_urls                        = ["https://www.example.com/"]
  supported_identity_providers         = ["Google"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = flatten(["openid", "email", "phone", "profile", aws_cognito_resource_server.resource.scope_identifiers])
}
