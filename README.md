# internal-s3-site
Use API GW and cognito for internal-only static sites

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.70.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_template_files"></a> [template\_files](#module\_template\_files) | hashicorp/dir/template | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_deployment.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_integration.get](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration.options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration_response.get_200](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_integration_response.options_200](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_method.get](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method.options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method_response.get_200](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource |
| [aws_api_gateway_method_response.options_200](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource |
| [aws_api_gateway_resource.object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_rest_api.internal_s3_site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |
| [aws_api_gateway_stage.dev](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage) | resource |
| [aws_iam_role.apigw_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.apigw_exec_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.apigw_exec_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_ownership_controls.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.allow_this_account_admins](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.public_access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_object.static_files](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_secretsmanager_secret.google_client_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.google_client_secret_current_initial](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_iam_policy.apigw_push_to_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy.s3_read_only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.apigw_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this_accounts_admins](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_roles.admins](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_roles) | data source |
| [aws_secretsmanager_secret_version.google_client_secret_current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_iam_role_regex"></a> [admin\_iam\_role\_regex](#input\_admin\_iam\_role\_regex) | A regex to match IAM roles that will have r/w permission on the s3 bucket | `string` | `"(AWSReservedSSO_AWSAdministratorAccess_|github_actions_admin).*"` | no |
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | The profile to use when configuring the AWS provider | `string` | `"personal"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The region to use when configuring the AWS provider | `string` | `"us-east-1"` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The bucket name that will host the origin static site | `string` | `"jmorgancusick-internal-s3-site"` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | This project's owner, which will be added as a tag to resources | `string` | `"Jack Cusick"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_internal_s3_site_dev_url"></a> [internal\_s3\_site\_dev\_url](#output\_internal\_s3\_site\_dev\_url) | The dev URL of the created API GW |
