
output "panorama_public_ips" {
  value = { for name, p in aws_eip.this : name => p.public_ip }
}

output "panorama_private_ips" {
  value = { for name, p in aws_eip.this : name => p.private_ip }
}
