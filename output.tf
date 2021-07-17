output "id" {
  description = "List of IDs of instances"
  value       = aws_instance.main.*.id
}

output "public_ip" {
  description = "List of public IP addresses assigned to the instances, of applicable"
  value       = aws_instance.main.*.public_ip
