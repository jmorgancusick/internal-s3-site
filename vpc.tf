
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.13"

  name = "internal-s3-site"
  cidr = "10.2.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
  public_subnets  = ["10.2.101.0/24", "10.2.102.0/24", "10.2.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  # Required by AWS LBC for subnet auto discovery - https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.9/deploy/subnet_discovery/
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_vpc_endpoint" "apigw" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.execute-api"
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true

  subnet_ids = module.vpc.private_subnets

  security_group_ids = [
    aws_security_group.apigw_vpce.id,
  ]

  tags = {
    Name = "internal_apigw"
  }
}

resource "aws_vpc_endpoint_policy" "execute" {
  vpc_endpoint_id = aws_vpc_endpoint.apigw.id
  policy          = data.aws_iam_policy_document.apigw_vpce.json
}


resource "aws_ec2_instance_connect_endpoint" "example" {
  subnet_id          = aws_instance.jumphost.subnet_id
  security_group_ids = [aws_security_group.ec2_ice.id]
}
