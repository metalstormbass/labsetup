#AWS Region
variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

#AWS VPC CIDR
variable "aws_vpc_cidr" {
  description = "aws vpc cidr"
  type        = string
  default     = "10.20.0.0/16"
}

#AWS AZ
variable "primary_az" {
  description = "primary AZ"
  default     = "us-east-1a"
}

#AWS Subnet CIDR
variable "aws_subnet_cidr" {
  description = "aws subnet cidr"
  type        = string
  default     = "10.20.0.0/24"
}
#Number of instances
variable "instances" {
  description = "number of ec2 instances"
  default = 12
}