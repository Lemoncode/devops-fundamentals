# PROVIDERS
variable "region" {
  type    = string
  default = "eu-west-3"
}

# NETWORKS
variable "vpc_cidr" {
  type    = string
  default = "10.2.0.0/16"
}

variable "availability_zone" {
  type    = string
  default = "eu-west-3a"
}

variable "subnet_cidr" {
  type    = string
  default = "10.2.254.0/24"
}

# INSTANCES
variable "private_instance_ip" {
  type    = string
  default = "10.2.254.10"
}

variable "ami" {
  type    = string
  default = "ami-02d0b1ffa5f16402d"
}

variable "key_name" {
  type = string 
  default = "devops_fundamentals_key_pair"
}

variable "instance_type" {
    type = string 
    default = "t3.micro"
}
