variable "availability_zone" {
  description = "Default AZ"
  default     = "us-east-1a"
}

variable "az_count" {
  description = "Number of availability zones to create"
  default     = 2
}

variable "desired_tasks" {
  description = "Desired number of instances"
  default     = 1
}

variable "app_port" {
  description = "Port the application listens on"
  default     = 80
}

variable "hosted_zone_name" {
  description = "Name of the DNS zone to use"
  default     = "reeb.me."
}

variable "secondary_zone_name" {
  description = "Name of the secondary DNS zone to use"
  default     = "tomreeb.com."
}

variable "subdomain" {
  description = "Subdomain to be used with hosted_zone_name (must end in .)"
  default     = "www."
}

variable "app_image" {
  description = "Image to use"
  default     = "tomreeb/dotcom:latest"
}

variable "fargate_cpu" {
  description = "Task CPU units"
  default     = "256"
}

variable "fargate_memory" {
  description = "Task memory (MiB)"
  default     = "512"
}

variable "elb_security_policy" {
  description = "ELB Security Policy Name"
  default     = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
}

variable "vpc_cidr_block" {
  description = "IP of VPC in CIDR Notation"
  default = "172.18.0.0/16"
}