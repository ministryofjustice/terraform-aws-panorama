#### Panorama AMI ID Lookup based on license type, region, version ####
data "aws_ami" "this" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "product-code"
    values = [var.pano_license_type_map[var.pano_license_type]]
  }

  filter {
    name   = "name"
    values = ["Panorama-AWS-${var.pano_version}*"]
  }
}

locals {
  # logger_panoramas = { for name, panorama in var.panoramas : name => panorama if contains(keys(panorama), "ebs") }
  # eip_panoramas    = { for name, panorama in var.panoramas : name => panorama if panorama.public_ip }
  logger_panoramas = { for panorama in var.panoramas : panorama.name => panorama if contains(keys(panorama), "ebs") }
  eip_panoramas    = { for panorama in var.panoramas : panorama.name => panorama if panorama.public_ip }
}

#### Create the Panorama Instances ####
resource "aws_instance" "this" {
  for_each                             = { for panorama in var.panoramas : panorama.name => panorama }
  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "stop"
  ebs_optimized                        = true
  ami                                  = data.aws_ami.this.id
  instance_type                        = lookup(each.value, "instance_type", "m4.2xlarge")
  tags = merge(
    {
      "Name" = each.key
    },
    var.tags,
  )

  root_block_device {
    delete_on_termination = true
  }

  key_name   = var.panorama_key_name
  monitoring = false

  private_ip = lookup(each.value, "private_ip", null)
  # associate_public_ip_address = lookup(each.value, "public_ip", null)

  vpc_security_group_ids = var.security_groups
  subnet_id              = each.value.subnet_id
  
  lifecycle {
    ignore_changes = [
      ami, ebs_optimized, aws_ebs_volume,
    ]
  }
}

resource "aws_ebs_volume" "this" {
  for_each          = local.logger_panoramas
  availability_zone = each.value.ebs.availability_zone
  encrypted         = lookup(each.value.ebs, "encrypted", true)
  iops              = lookup(each.value.ebs, "iops", null)
  size              = lookup(each.value.ebs, "size", 2000)
  snapshot_id       = lookup(each.value.ebs, "snapshot_id", null)
  type              = lookup(each.value.ebs, "type", null)
  kms_key_id        = lookup(each.value.ebs, "kms_key_id", null)
  tags = merge({
    "Name" = each.key
    },
    var.tags,
    lookup(each.value, "tags", {})
  )
}

resource "aws_volume_attachment" "this" {
  for_each     = local.logger_panoramas
  device_name  = lookup(each.value.ebs, "device_name", "/dev/sdf")
  instance_id  = aws_instance.this[each.key].id
  volume_id    = aws_ebs_volume.this[each.key].id
  force_detach = lookup(each.value, "force_detach", null)
  skip_destroy = lookup(each.value, "skip_destroy", null)
}

#### Create the Panorama elastic IPs ####
resource "aws_eip" "this" {
  for_each         = local.eip_panoramas
  vpc              = true
  instance         = aws_instance.this[each.key].id
  public_ipv4_pool = var.public_ipv4_pool

  tags = merge({ "Name" = "${each.key}-eip" }, var.tags)

  depends_on = [aws_instance.this]
}
