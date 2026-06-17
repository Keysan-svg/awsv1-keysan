# Bastion Host

resource "aws_security_group" "keysan_bastion_sg" {
  name        = "keysan-bastion-sg"
  description = "SSH access to bastion host"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH depuis mon IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    description = "Tout le trafic sortant"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "keysan-bastion"
  }
}

resource "aws_instance" "keysan_bastion_vm" {
  ami                         = var.keysan_vm_image
  instance_type               = var.keysan_vm_instance_type
  subnet_id                   = local.selected_subnet_id
  vpc_security_group_ids      = [aws_security_group.keysan_bastion_sg.id]
  key_name                    = aws_key_pair.keysan_keypair.key_name
  associate_public_ip_address = true

  tags = {
    Name = "keysan-bastion"
  }
}

output "bastion_public_ip" {
  description = "IP publique du bastion"
  value       = aws_instance.keysan_bastion_vm.public_ip
}