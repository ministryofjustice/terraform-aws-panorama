provider "aws" {
  region = "eu-north-1" 
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "panorama-test"
  cidr = "192.168.254.0/24"

  azs             = ["eu-north-1a"]
  public_subnets  = ["192.168.254.0/28"]

  tags = {
    Terraform = "true"
    Environment = "test"
  }
}

module "panorama" {
  source = "../../"
  panoramas = {
    panorama1 = {
      instance_type = "t3.xlarge",
      public_ip =  true
      subnet_id = module.vpc.public_subnets[0]
    }
  }
  fw_key_name = var.fw_key_name
}        
