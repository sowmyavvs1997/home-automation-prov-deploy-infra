variable "name" { type = string }
variable "security_group_ids" { type = list(string) }
variable "subnets" { type = list(string) }
variable "lb_name" {}
variable "lb_target_group_name" {}
variable "container_port" {}
variable "protocol" {}
variable "vpc_id" {}
variable "lb_port" {}
variable "subnet_private_ids" {}
