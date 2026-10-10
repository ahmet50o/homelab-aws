# ============================================================
# Bastion
# ============================================================

output "bastion_public_ip" {
  description = "Public IP of the bastion host — SSH entry point"
  value       = aws_eip.bastion.public_ip
}

# ============================================================
# All VM private IPs
# ============================================================

output "vm_ips" {
  description = "Private IPs of all VMs"
  value = {
    for name, vm in aws_instance.vms : name => vm.private_ip
  }
}
