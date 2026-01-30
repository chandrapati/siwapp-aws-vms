# outputs.tf

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}

output "subnet_id" {
  description = "Subnet ID"
  value       = aws_subnet.subnet.id
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.sg.id
}

output "db_lb_public_ip" {
  description = "Database Load Balancer Public IP"
  value       = aws_instance.dblb.public_ip
}

output "db1_public_ip" {
  description = "Database Server 1 Public IP"
  value       = aws_instance.db1.public_ip
}

output "db2_public_ip" {
  description = "Database Server 2 Public IP"
  value       = aws_instance.db2.public_ip
}

output "db3_public_ip" {
  description = "Database Server 3 Public IP"
  value       = aws_instance.db3.public_ip
}

output "app_lb_public_ip" {
  description = "Application Load Balancer Public IP"
  value       = aws_instance.applb.public_ip
}

output "app1_public_ip" {
  description = "Application Server 1 Public IP"
  value       = aws_instance.app1.public_ip
}

output "app2_public_ip" {
  description = "Application Server 2 Public IP"
  value       = aws_instance.app2.public_ip
}

output "app3_public_ip" {
  description = "Application Server 3 Public IP"
  value       = aws_instance.app3.public_ip
}

output "all_instance_ips" {
  description = "All instance IPs in a list"
  value = {
    db_lb  = aws_instance.dblb.public_ip
    db1    = aws_instance.db1.public_ip
    db2    = aws_instance.db2.public_ip
    db3    = aws_instance.db3.public_ip
    app_lb = aws_instance.applb.public_ip
    app1   = aws_instance.app1.public_ip
    app2   = aws_instance.app2.public_ip
    app3   = aws_instance.app3.public_ip
  }
}
