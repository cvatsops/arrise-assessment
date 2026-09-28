output "instance_ids" {
  description = "Map of logical instance name -> instance ID"
  value       = { for name, inst in aws_instance.this : name => inst.id }
}

output "instance_private_ips" {
  description = "Map of logical instance name -> private IP address"
  value       = { for name, inst in aws_instance.this : name => inst.private_ip }
}
