output "alb_dns_name" {
    value       = aws_lb.webserver.dns_name
    description = "DNS name of the load balancer"
}

output "alb_arn" {
    value       = aws_lb.webserver.arn
    description = "ARN of the load balancer"
}

output "target_group_arn" {
    value       = aws_lb_target_group.webserver.arn
    description = "ARN of the target group"
}

output "security_group_id" {
    value       = aws_security_group.webserver_sg.id
    description = "ID of the security group"
}

output "asg_name" {
    value       = aws_autoscaling_group.webserver.name
    description = "Name of the Auto Scaling Group"
}

