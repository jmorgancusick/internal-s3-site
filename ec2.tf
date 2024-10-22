resource "random_shuffle" "public_subnet" {
  input        = module.vpc.public_subnets
  result_count = 1
}

resource "aws_instance" "jumphost" {
  ami           = data.aws_ami.ubuntu_arm.id
  instance_type = "t4g.micro"

  associate_public_ip_address = true

  subnet_id              = random_shuffle.public_subnet.result[0]
  vpc_security_group_ids = [aws_security_group.jumphost.id]

  user_data = templatefile(
    "${path.module}/user_data.tftpl", 
    {
      proxy_username = var.proxy_username,
      proxy_password = random_password.proxy_password.result,
    }
  )
  user_data_replace_on_change = true

  tags = {
    Name = var.jumphost_name
  }
}

# ==========================================
# ============== Jumphost SG ===============
# ==========================================

resource "aws_security_group" "jumphost" {
  name        = var.jumphost_name
  description = "Allow HTTPS proxy traffic on ${var.proxy_port} and SSH on jumphost"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = var.jumphost_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "jumphost_allow_ec2_ice_ssh" {
  security_group_id = aws_security_group.jumphost.id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22

  referenced_security_group_id = aws_security_group.ec2_ice.id
}

resource "aws_vpc_security_group_ingress_rule" "jumphost_allow_https_proxy_ipv4" {
  security_group_id = aws_security_group.jumphost.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.proxy_port
  ip_protocol       = "tcp"
  to_port           = var.proxy_port
}

resource "aws_vpc_security_group_egress_rule" "jumphost_allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.jumphost.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "jumphost_allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.jumphost.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# ==========================================
# ============= APIGW VPCE SG ==============
# ==========================================

resource "aws_security_group" "apigw_vpce" {
  name        = local.api_gateway_vpc_endpoint_security_group_name
  description = "Allow HTTPS traffic from the jumphost"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = local.api_gateway_vpc_endpoint_security_group_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "apigw_vpce_allow_https_proxy" {
  security_group_id = aws_security_group.apigw_vpce.id
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443

  referenced_security_group_id = aws_security_group.jumphost.id
}

resource "aws_vpc_security_group_egress_rule" "apigw_vpce_allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.apigw_vpce.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# ==========================================
# =============== EC2 ICE SG ===============
# ==========================================

resource "aws_security_group" "ec2_ice" {
  name        = local.ec2_instance_connect_endpoint_security_group_name
  description = "EC2 Instance Connect Endpoint"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = local.ec2_instance_connect_endpoint_security_group_name
  }
}

resource "aws_vpc_security_group_egress_rule" "ec2_ice_allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.ec2_ice.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
