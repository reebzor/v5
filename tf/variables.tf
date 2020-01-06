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
  default     = 3
}

variable "app_port" {
  description = "Port the application listens on"
  default     = 80
}

variable "hosted_zone_name" {
  description = "Name of the DNS zone to use"
  default     = "reeb.me."
}

variable "subdomain" {
  description = "Subdomain to be used with hosted_zone_name (must end in .)"
  default     = "fargate."
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
