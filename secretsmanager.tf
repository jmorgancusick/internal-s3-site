resource "aws_secretsmanager_secret" "google_client_secret" {
  name                    = "google-idp-oauth2-client-secret"
  recovery_window_in_days = 0 # QoL improvement for destroying and remaking
}

resource "aws_secretsmanager_secret_version" "google_client_secret_current_initial" {
  secret_id = aws_secretsmanager_secret.google_client_secret.id
  secret_string = jsonencode({
    "client_id":"placeholder",
    "project_id":"placeholder",
    "auth_uri":"placeholder",
    "token_uri":"placeholder",
    "auth_provider_x509_cert_url":"placeholder",
    "client_secret":"placeholder"
  })

  version_stages = ["AWSINITIAL", "AWSCURRENT"]

  lifecycle {
    ignore_changes = [
      version_stages,
    ]
  }
}
