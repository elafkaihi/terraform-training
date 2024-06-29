module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  name                 = var.VPC_NAME
  cidr                 = var.VPC_CIDR
  azs                  = [var.Zone1, var.Zone2, var.Zone3]
  private_subnets      = [var.PrivSub1_CIDR, var.PrivSub2_CIDR, var.PrivSub3_CIDR]
  public_subnets       = [var.PubSub1_CIDR, var.PubSub2_CIDR, var.PubSub3_CIDR]
  enable_nat_gateway   = true
  enable_vpn_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
  vpc_tags = {
    Name = var.VPC_NAME
  }

}