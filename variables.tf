variable "aws_region" {
  description = "Region AWS"
  type        = string
  default     = "eu-west-3"
}


variable "vpc_id" {
  description = "ID du VPC AWS utilise"
  type        = string
}


variable "keysan_vm_image" {
  description = "AMI utilisee pour les instances EC2"
  type        = string
}


variable "keysan_vm_instance_type" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t3.micro"
}


variable "keysan_ssh_public_key_path" {
  description = "Chemin vers la cle publique SSH"
  type        = string
  default     = "/home/kali/.ssh/id_ed25519.pub"
}


variable "my_ip" {
  description = "Adresse IP publique autorisee pour SSH vers le bastion"
  type        = string
}