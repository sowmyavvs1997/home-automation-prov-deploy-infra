variable "sg_name" { type = string }
variable "vpc_id" { type = string }

variable "allow_ports" {
  description = "List of ports to allow ingress for"
  type        = list(number)
  default     = [1883, 8080, 6379, 5432]
}

variable "allow_cidr" {
  description = "CIDR block allowed for ingress traffic"
  type        = string
  default     = "0.0.0.0/0"
}