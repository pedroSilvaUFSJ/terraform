variable "region" {
  description = "region where the aws server is installed"
  default = "eu-south-1"
  type = string
}

variable "availability_zone" {
  description = "region where the aws server is installed"
  default = "eu-south-1c"
  type = string
}

variable "subnet_prefix" {
  description = "subnet ip address"
  default = "10.0.1.0/24"
  type = string
}

variable "access_key" {
  description = "user access_key from IAM AWS"
  type = string
}

variable "secret_key" {
  description ="user secret_key from IAM AWS"
  type = string
}

variable "ami" {
  description = "ami server info can be gotten on aws instance settings"
  default = "ami-018f430e4f5375e69"
  type = string
}

variable "key_name" {
  description = "the name of the 'key pairs' generated on aws"
  default =  "terraform-pair"
  type = string
}

variable "instance_type" {
  description = "instance_type server info can be gotten on aws instance settings"
  default =  "t3.micro"
  type = string
}