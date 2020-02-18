# Firewall version for AMI lookup

variable "pano_version" {
  description = "Select which Panorama version to deploy"
  default     = "9.0.5"
  #default     = "9.0.3"
  # Acceptable Values Below
  #default = "8.1.2"
  #default = "8.1.0"
}

# License type for AMI lookup
variable "pano_license_type" {
  description = "Select License type (byol only for Panorama)"
  default     = "byol"
}

# Product code map based on license type for ami filter

variable "pano_license_type_map" {
  type = map(string)
  default = {
    "byol" = "eclz7j04vu9lf8ont8ta3n17o"
  }
}

# Panorama Deployment Variables
variable "panoramas" {
  description = "Panoramas to be built"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "fw_key_name" {
  description = "SSH Public Key to use w/firewall"
  default     = ""
}

variable "security_groups" {
  description = "list of security groups"
  default = null
}
