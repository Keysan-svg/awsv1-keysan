output "bastion_public_ip" {
  value = aws_instance.keysan_bastion_vm.public_ip
}

output "target_private_ip" {
  value = aws_instance.keysan_target_vm.private_ip
}

output "bastion_security_group_id" {
  value = aws_security_group.keysan_bastion_sg.id
}

output "target_security_group_id" {
  value = aws_security_group.keysan_target_sg.id
}

output "network_acl_id" {
  value = aws_network_acl.keysan_nacl.id
}
