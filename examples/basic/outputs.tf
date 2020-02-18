output "subnet" {
  value = module.vpc.public_subnets[0]
}
