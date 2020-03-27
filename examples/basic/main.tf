provider "aws" {
  region = "eu-north-1" 
}

module "vpc" {
  source     = "git::https://gitlab.com/public-tf-modules/terraform-aws-vpc?ref=v0.1.0"
  cidr_block = "10.0.0.0/16"
  subnets = {
    public-1a  = { cidr = "10.0.0.0/24", az = "eu-north-1a", route_table = "public" },
  }
  public_rts = ["public"]
}

module "panorama" {
  source = "../../"
  panoramas = {
    panorama1 = {
      instance_type = "t3.xlarge",
      public_ip =  true
      subnet_id = module.vpc.subnets["public-1a"].id
    }
  }
  fw_key_name = var.fw_key_name
}        
