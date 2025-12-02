# Get database information from remote state (if backend config provided)
data "terraform_remote_state" "db" {
    backend = "s3"
    config = {
        bucket = var.db_state_backend_bucket
        key    = var.db_state_backend_key
        region = var.aws_region
    }
}

# Security Group
resource "aws_security_group" "webserver_sg" {
    name        = "${var.environment}-webserver-sg"
    description = "Security group for ${var.environment} webserver cluster"
    vpc_id      = var.vpc_id

    tags = merge(
        {
            Name        = "${var.environment}-webserver-sg"
            Environment = var.environment
        },
        var.tags
    )
}

# Security Group Rules
resource "aws_security_group_rule" "allow_http_inbound" {
    type              = "ingress"
    security_group_id = aws_security_group.webserver_sg.id
    from_port         = var.server_port
    to_port           = var.server_port
    protocol          = local.tcp_protocol
    cidr_blocks       = [local.all_cidr]
    description       = "HTTP server port"
}

# Conditionally allow SSH
resource "aws_security_group_rule" "allow_ssh_inbound" {
    count             = var.enable_ssh ? 1 : 0
    type              = "ingress"
    security_group_id = aws_security_group.webserver_sg.id
    from_port         = local.ssh_port
    to_port           = local.ssh_port
    protocol          = local.tcp_protocol
    cidr_blocks       = [local.all_cidr]
    description       = "SSH access"
}

resource "aws_security_group_rule" "allow_all_outbound" {
    type              = "egress"
    security_group_id = aws_security_group.webserver_sg.id
    from_port         = local.any_port
    to_port           = local.any_port
    protocol          = local.all_protocols
    cidr_blocks       = [local.all_cidr]
    description       = "Allow all outbound traffic"
}

# Common values and constants
locals {
    # Network constants (used in multiple places)
    any_port     = 0
    ssh_port     = 22
    all_protocols = "-1"
    tcp_protocol = "tcp"
    http_protocol = "HTTP"
    all_cidr     = "0.0.0.0/0"
    
    # User data hash for launch template update detection
    user_data_hash = filebase64sha256("${path.module}/user_data.sh")
    user_data_hash_short = substr(local.user_data_hash, 0, 16)  # First 16 chars for readability
}

# Launch Template for Auto Scaling Group
resource "aws_launch_template" "webserver" {
    name_prefix          = "${var.environment}-webserver-"
    image_id             = var.ami_id
    instance_type        = var.instance_type
    vpc_security_group_ids = [aws_security_group.webserver_sg.id]
    update_default_version = true  # Automatically update default version when changed

    user_data = base64encode(templatefile("${path.module}/user_data.sh", {
        server_port         = var.server_port
        db_instance_address = data.terraform_remote_state.db.outputs.db_instance_address
        db_instance_port    = data.terraform_remote_state.db.outputs.db_instance_port
    }))

    # Include user_data hash in tags to force update detection
    tags = {
        UserDataHash = local.user_data_hash_short
    }

    tag_specifications {
        resource_type = "instance"
        tags = merge(
            {
                Name        = "${var.environment}-webserver-instance"
                Environment = var.environment
                UserDataHash = local.user_data_hash_short
            },
            var.tags
        )
    }

    lifecycle {
        create_before_destroy = true
    }
}

# Target Group for ALB
resource "aws_lb_target_group" "webserver" {
    name     = "${var.environment}-webserver-tg"
    port     = var.server_port
    protocol = local.http_protocol
    vpc_id   = var.vpc_id

    health_check {
        path                = "/"
        protocol            = local.http_protocol
        matcher             = "200"
        interval            = 15
        timeout             = 3
        healthy_threshold   = 2
        unhealthy_threshold = 2
    }

    tags = merge(
        {
            Name        = "${var.environment}-webserver-tg"
            Environment = var.environment
        },
        var.tags
    )
}

# Auto Scaling Group
resource "aws_autoscaling_group" "webserver" {
    name = "${var.environment}-webserver-asg"

    launch_template {
        id      = aws_launch_template.webserver.id
        version = "$Latest"  # Always use latest version
    }

    min_size         = var.min_size
    max_size         = var.max_size
    desired_capacity = var.min_size

    vpc_zone_identifier      = var.subnet_ids
    target_group_arns         = [aws_lb_target_group.webserver.arn]
    health_check_type         = "ELB"
    health_check_grace_period = 300

    # Instance refresh configuration
    instance_refresh {
        strategy = "Rolling"
        preferences {
            min_healthy_percentage = 50
        }
    }

    tag {
        key                 = "Name"
        value               = "${var.environment}-webserver-asg"
        propagate_at_launch = true
    }

    tag {
        key                 = "Environment"
        value               = var.environment
        propagate_at_launch = true
    }

    dynamic "tag" {
        for_each = var.tags
        content {
            key                 = tag.key
            value               = tag.value
            propagate_at_launch = true
        }
    }
}

# Application Load Balancer
resource "aws_lb" "webserver" {
    name               = "${var.environment}-webserver-alb"
    load_balancer_type = "application"
    security_groups    = [aws_security_group.webserver_sg.id]
    subnets            = var.subnet_ids

    enable_deletion_protection = false

    tags = merge(
        {
            Name        = "${var.environment}-webserver-alb"
            Environment = var.environment
        },
        var.tags
    )
}

# ALB Listener
resource "aws_lb_listener" "webserver" {
    load_balancer_arn = aws_lb.webserver.arn
    port              = var.server_port
    protocol          = local.http_protocol

    default_action {
        type = "fixed-response"
        fixed_response {
            content_type = "text/plain"
            message_body = "404: page not found"
            status_code  = "404"
        }
    }
}

# ALB Listener Rule
resource "aws_lb_listener_rule" "webserver" {
    listener_arn = aws_lb_listener.webserver.arn
    priority     = 100

    condition {
        path_pattern {
            values = ["*"]
        }
    }

    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.webserver.arn
    }

    tags = merge(
        {
            Name        = "${var.environment}-webserver-listener-rule"
            Environment = var.environment
        },
        var.tags
    )
}

