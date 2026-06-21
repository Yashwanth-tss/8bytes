variable "aws_region" {
  description = "AWS region to deploy resources to"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "8bytes"
}

variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "quotesdb"
}
variable "app_port" {
  description = "Port for the application"
  type        = number
  default     = 80
}

variable "grafana_port" {
    description = "Port for the grafana"
    type        = number
    default     = 3000
}

variable "my_ip" {
  description = "My IP address"
  type        = string
  default     = "0.0.0.0/0"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "assignment-key"
}
