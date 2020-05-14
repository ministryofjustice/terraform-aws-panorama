
output "panorama_ips" {
  value = { for name, p in aws_eip.this : name => [p.public_ip, p.private_ip] }
}
