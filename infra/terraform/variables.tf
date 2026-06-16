variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-3"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID used for the Keysan infrastructure"
}

variable "keysan_vm_image" {
  type        = string
  description = "AMI used for Keysan EC2 instances"
}

variable "keysan_vm_instance_type" {
  type        = string
  description = "EC2 instance type for Keysan instances"
  default     = "t3.micro"
}

variable "keysan_ssh_public_key_path" {
  type        = string
  description = "Path to the SSH public key uploaded as an EC2 key pair"
  default     = "~/.ssh/id_ed25519.pub"
}