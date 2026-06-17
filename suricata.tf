resource "aws_security_group" "keysan_sonde_sg" {
  name        = "keysan-sonde-sg"
  description = "Sonde Suricata : SSH + ICMP depuis le bastion"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH depuis le bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.keysan_bastion_sg.id]
  }

  ingress {
    description     = "ICMP depuis le bastion"
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"
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
    Name = "keysan-sonde-sg"
  }
}


resource "aws_instance" "keysan_sonde_vm" {
  ami                         = var.keysan_vm_image
  instance_type               = var.keysan_vm_instance_type
  subnet_id                   = local.selected_subnet_id
  vpc_security_group_ids      = [aws_security_group.keysan_sonde_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.keysan_keypair.key_name

  user_data = <<EOT
#!/bin/bash

apt-get update

apt-get install -y software-properties-common

add-apt-repository -y ppa:oisf/suricata-stable

apt-get update

apt-get install -y suricata

suricata-update

IFACE=$(ip route | awk '/default/ {print $5; exit}')

sed -i "s/interface: eth0/interface: $IFACE/" /etc/suricata/suricata.yaml

echo 'alert icmp any any -> $HOME_NET any (msg:"KEYSAN ICMP detecte"; sid:1000001; rev:1;)' >> /var/lib/suricata/rules/suricata.rules

systemctl enable suricata

systemctl restart suricata

EOT

  tags = {
    Name = "keysan-sonde"
  }
}


output "keysan_sonde_private_ip" {
  description = "IP privée de la sonde Suricata"
  value       = aws_instance.keysan_sonde_vm.private_ip
}