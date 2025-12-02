variable "environment" {
    description = "Environment name (staging, production, etc.)"
    type        = string
}

variable "aws_region" {
    description = "AWS region to deploy resources"
    type        = string
}

variable "server_port" {
    description = "The port the server will use for HTTP requests"
    type        = number
    # default     = 8080
}

variable "instance_type" {
    description = "EC2 instance type"
    type        = string
    # default     = "t3.micro"
}

variable "ami_id" {
    description = "AMI ID to use for instances"
    type        = string
    # default     = "ami-0fb653ca2d3203ac1"
}

variable "min_size" {
    description = "Minimum number of instances in ASG"
    type        = number
    # default     = 2
}

variable "max_size" {
    description = "Maximum number of instances in ASG"
    type        = number
    # default     = 10
}

variable "vpc_id" {
    description = "VPC ID where resources will be created"
    type        = string
}

variable "subnet_ids" {
    description = "List of subnet IDs for ASG and ALB"
    type        = list(string)
}

# Remote state backend configuration (optional - if not provided, db variables must be set)
variable "db_state_backend_bucket" {
    description = "S3 bucket name for database remote state"
    type        = string
}

variable "db_state_backend_key" {
    description = "S3 key path for database remote state"
    type        = string
}

variable "enable_ssh" {
    description = "Enable SSH access (port 22)"
    type        = bool
    # default     = false
}

variable "tags" {
    description = "Additional tags to apply to resources"
    type        = map(string)
    default     = {}
}

