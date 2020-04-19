variable "prefix" {
  description = "The common prefix for names."
  type        = string
  default     = "Jira"
}

variable "vpc_id" {
  description = "AWS VPC id."
  type        = string
}

variable "subnet_ids" {
  description = "AWS VPC subnet ids."
  type        = set(string)
}

variable "instance_type" {
  description = "AWS EC2 instance type."
  type        = string
  default     = "t3a.medium"
}

variable "max_number_of_instances" {
  description = "AWS EC2 autoscaling group max size."
  type        = number
  default     = 1
}

variable "min_number_of_instances" {
  description = "AWS EC2 autoscaling group min size."
  type        = number
  default     = 1
}

variable "desired_number_of_instances" {
  description = "AWS EC2 autoscaling group desired capacity."
  type        = number
  default     = 1
}

variable "instance_root_volume_size" {
  description = "AWS EC2 instance root volume size."
  type        = number
  default     = 8
}

variable "instance_ingress" {
  description = <<EOT
                  List of configuration objects for ingress.
                  Schema: { port = number, protocol = string, cidr_blocks = set(string)}
                  Only port is mandatory
                  EOT
  type        = list(any)
  default     = []
}

variable "ssh_whitelist" {
  description = "Whitelist of cidr blocks for access to EC2 instances"
  type        = set(string)
}

variable "public_key_path" {
  description = "Path to the RSA public key."
  type        = string
}
