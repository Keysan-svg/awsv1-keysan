# Sous-réseau privé
resource "aws_subnet" "keysan_private_subnet" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.100.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false

  tags = {
    Name = "keysan-private-subnet"
  }
}

# Elastic IP pour la NAT Gateway
resource "aws_eip" "keysan_nat_eip" {
  domain = "vpc"

  tags = {
    Name = "keysan-nat-eip"
  }
}

# NAT Gateway dans le subnet public
resource "aws_nat_gateway" "keysan_nat_gateway" {
  allocation_id = aws_eip.keysan_nat_eip.id
  subnet_id     = local.selected_subnet_id

  tags = {
    Name = "keysan-nat-gateway"
  }
}

# Table de routage privée
resource "aws_route_table" "keysan_private_rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.keysan_nat_gateway.id
  }

  tags = {
    Name = "keysan-private-rt"
  }
}

resource "aws_route_table_association" "keysan_private_rta" {
  subnet_id      = aws_subnet.keysan_private_subnet.id
  route_table_id = aws_route_table.keysan_private_rt.id
}

# Security Group de la machine privée
resource "aws_security_group" "keysan_private_sg" {
  name        = "keysan-private-sg"
  description = "SSH only from bastion"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH depuis le bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.keysan_bastion_sg.id]
  }

  egress {
    description = "Tout le trafic sortant"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "keysan-private-sg"
  }
}

# Instance privée
resource "aws_instance" "keysan_private_vm" {
  ami                    = var.keysan_vm_image
  instance_type          = var.keysan_vm_instance_type
  subnet_id              = aws_subnet.keysan_private_subnet.id
  vpc_security_group_ids = [aws_security_group.keysan_private_sg.id]
  key_name               = aws_key_pair.keysan_keypair.key_name

  tags = {
    Name = "keysan-private-vm"
  }
}

output "keysan_private_ip" {
  description = "IP privée de la machine cible"
  value       = aws_instance.keysan_private_vm.private_ip
}