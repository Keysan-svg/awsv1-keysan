provider "aws" {
  region = var.aws_region
}

data "aws_subnets" "vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

locals {
  selected_subnet_id = sort(data.aws_subnets.vpc_subnets.ids)[0]
}

resource "aws_key_pair" "keysan_keypair" {
  key_name   = "keysan-keypair"
  public_key = file(var.keysan_ssh_public_key_path)
}

resource "aws_security_group" "keysan_bastion_sg" {
  name        = "keysan-bastion-sg"
  description = "SSH access to the bastion host"
  vpc_id      = var.vpc_id

  tags = {
    Name = "keysan-bastion-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "keysan_bastion_ssh_ingress" {
  security_group_id = aws_security_group.keysan_bastion_sg.id
  description       = "SSH from anywhere"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "keysan_bastion_egress" {
  security_group_id = aws_security_group.keysan_bastion_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "keysan_target_sg" {
  name        = "keysan-target-sg"
  description = "Allow access to target only from bastion"
  vpc_id      = var.vpc_id

  tags = {
    Name = "keysan-target-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "keysan_target_ssh_ingress" {
  security_group_id            = aws_security_group.keysan_target_sg.id
  description                  = "SSH from bastion"
  from_port                    = 22
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.keysan_bastion_sg.id
  to_port                      = 22
}

resource "aws_vpc_security_group_ingress_rule" "keysan_target_icmp_ingress" {
  security_group_id            = aws_security_group.keysan_target_sg.id
  description                  = "ICMP from bastion"
  from_port                    = -1
  ip_protocol                  = "icmp"
  referenced_security_group_id = aws_security_group.keysan_bastion_sg.id
  to_port                      = -1
}

resource "aws_vpc_security_group_egress_rule" "keysan_target_egress" {
  security_group_id = aws_security_group.keysan_target_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "keysan_bastion_vm" {
  ami                         = var.keysan_vm_image
  instance_type               = var.keysan_vm_instance_type
  subnet_id                   = local.selected_subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.keysan_bastion_sg.id]
  key_name                    = aws_key_pair.keysan_keypair.key_name

  tags = {
    Name = "keysan-bastion"
  }
}

resource "aws_instance" "keysan_target_vm" {
  ami                         = var.keysan_vm_image
  instance_type               = var.keysan_vm_instance_type
  subnet_id                   = local.selected_subnet_id
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.keysan_target_sg.id]
  key_name                    = aws_key_pair.keysan_keypair.key_name

  tags = {
    Name = "keysan-target"
  }
}

resource "aws_network_acl" "keysan_nacl" {
  vpc_id     = var.vpc_id
  subnet_ids = [local.selected_subnet_id]

  tags = {
    Name = "keysan-nacl"
  }
}

resource "aws_network_acl_rule" "keysan_nacl_ingress_ssh" {
  network_acl_id = aws_network_acl.keysan_nacl.id
  egress         = false
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "keysan_nacl_egress_ephemeral" {
  network_acl_id = aws_network_acl.keysan_nacl.id
  egress         = true
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}