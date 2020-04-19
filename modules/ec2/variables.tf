variable "prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = set(string)
}

variable "instance_type" {
  type = string
}

variable "max_number_of_instances" {
  type = number
}

variable "min_number_of_instances" {
  type = number
}

variable "instance_root_volume_size" {
  type = number
}

variable "instance_ingress" {
  type = list(any)
}

variable "ssh_whitelist" {
  type = set(string)
}

variable "public_key_path" {
  type = string
}

variable "ecs_cluster" {
  type = string
}
