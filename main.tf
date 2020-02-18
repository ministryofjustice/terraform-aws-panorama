#### Panorama AMI ID Lookup based on license type, region, version ####

data "aws_ami" "this" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "product-code"
    values = ["${var.pano_license_type_map[var.pano_license_type]}"]
  }

  filter {
    name   = "name"
    values = ["Panorama-AWS-${var.pano_version}*"]
  }
}

#### Create the Panorama Instances ####

resource "aws_instance" "this" {
  for_each = var.panoramas
  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "stop"
  ebs_optimized                        = true
  ami                                  = data.aws_ami.this.id
  instance_type                        = each.value.instance_type
  tags = merge(
    {
      "Name" = each.key
    },
    var.tags,
  )

  root_block_device {
    delete_on_termination = true
  }

  key_name   = var.fw_key_name
  monitoring = false

  private_ip = lookup(each.value, "private_ip", null)
  associate_public_ip_address = lookup(each.value, "public_ip", null)
  
  vpc_security_group_ids = var.security_groups
  subnet_id = each.value.subnet_id
}
