data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.web_ami.name]
  }

  filter {
    name   = "virtualization-type"
    values = [var.web_ami.virt_type]
  }

  owners = [var.web_ami.owner]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = var.environment.name

  cidr            = "${var.environment.network_prefix}.0.0/16"
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["${var.environment.network_prefix}.1.0/24", "${var.environment.network_prefix}.2.0/24", "${var.environment.network_prefix}.3.0/24"]
  public_subnets  = ["${var.environment.network_prefix}.101.0/24", "${var.environment.network_prefix}.102.0/24", "${var.environment.network_prefix}.103.0/24"]

  enable_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = var.environment.name
  }
}

module "web_security_group" {
  source      = "terraform-aws-modules/security-group/aws"

  name        = "${var.environment.name}-web-sg"
  description = "Allow HTTP/HTTPS inbound and ALL outbound"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]

  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.9.0"
  
  name = "${var.environment.name}-web-asg"

  min_size            = 3
  max_size            = 5
  vpc_zone_identifier = module.vpc.public_subnets
  target_group_arns   = module.alb.target_group_arns
  security_groups     = [module.web_security_group.security_group_id]

  image_id      = data.aws_ami.app_ami.id
  instance_type = var.instance_type
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "${var.environment.name}-web-alb"

  load_balancer_type = "application"

  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [module.web_security_group.security_group_id]

  target_groups = [
    {
      name_prefix      = "${var.environment.name}-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Terraform = "true"
    Environment = var.environment.name
  }
}