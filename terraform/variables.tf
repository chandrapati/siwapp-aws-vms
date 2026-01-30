# variables.tf
 
# Variables for general information
######################################
 
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
 
variable "owner" {
  description = "Configuration owner"
  type        = string
  default     = "sujichan"
}
 
variable "aws_region_az" {
  description = "AWS region availability zone"
  type        = string
  default     = "a"
}
 
 
# Variables for VPC
######################################
 
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.255.0.0/16"
}
 
variable "vpc_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}
 
variable "vpc_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "pvt_key" {
  description = "Path to private key file"
  type        = string
  default     = "./siwapp-key.pem"
}

variable "s3_bucket_name" {
  description = "S3 bucket name for VPC flow logs"
  type        = string
  default     = "secureworkloadvpcflowbuckets"
}
 
# Variables for Security Group
######################################
 
variable "sg_ingress_proto" {
  description = "Protocol used for the ingress rule"
  type        = string
  default     = "-1"
}
 
variable "sg_ingress_all" {
  description = "Port used for the ingress rule"
  type        = number
  default     = 0
}
 
variable "sg_egress_proto" {
  description = "Protocol used for the egress rule"
  type        = string
  default     = "-1"
}
 
variable "sg_egress_all" {
  description = "Port used for the egress rule"
  type        = number
  default     = 0
}
 
variable "sg_all_cidr_block" {
  description = "CIDR block for the security group rules"
  type        = string
  default     = "0.0.0.0/1"
}
 
 
# Variables for Subnet
######################################
 
variable "sbn_public_ip" {
  description = "Assign public IP to the instance launched into the subnet"
  type        = bool
  default     = true
}
 
variable "sbn_cidr_block" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.255.1.0/24"
}
 
 
# Variables for Route Table
######################################
 
variable "rt_cidr_block" {
  description = "CIDR block for the route table"
  type        = string
  default     = "0.0.0.0/0"
}
 
 
# Variables for Instance
######################################
 
variable "instance_ami" {
  description = "ID of the AMI used"
  type        = string
  default     = "ami-0453ec754f44f9a4a"  # CentOS Stream 9 in us-east-1
}
 
variable "instance_type" {
  description = "Type of the instance"
  type        = string
  default     = "t3.micro"
}
 
variable "key_pair" {
  description = "SSH Key pair used to connect"
  type        = string
  default     = "siwapp-east-1"
}
 
variable "root_device_type" {
  description = "Type of the root block device"
  type        = string
  default     = "gp3"
}
 
variable "root_device_size" {
  description = "Size of the root block device"
  type        = number
  default     = 50
}
