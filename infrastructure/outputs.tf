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
  description = "Private IPs of all VMs — use for Ansible inventory"
  value = {
    for name, vm in aws_instance.vms : name => vm.private_ip
  }
}

# ============================================================
# Ansible inventory (ready to copy)
# ============================================================

output "ansible_inventory" {
  description = "Ansible inventory — copy to configuration/inventories/homelab/hosts.ini"
  value = <<-INI
    [bastion]
    ${aws_instance.vms["vm-bastion"].private_ip}

    [management]
    ${aws_instance.vms["vm-dns"].private_ip}
    ${aws_instance.vms["vm-storage"].private_ip}

    [security]
    ${aws_instance.vms["vm-ca"].private_ip}
    ${aws_instance.vms["vm-vault"].private_ip}

    [platform]
    ${aws_instance.vms["vm-gitlab"].private_ip}
    ${aws_instance.vms["vm-db"].private_ip}
    ${aws_instance.vms["vm-keycloak"].private_ip}
    ${aws_instance.vms["vm-proxy"].private_ip}

    [k8s_masters]
    ${aws_instance.vms["vm-k8s-master-01"].private_ip}
    ${aws_instance.vms["vm-k8s-master-02"].private_ip}

    [k8s_workers]
    ${aws_instance.vms["vm-k8s-worker-01"].private_ip}
    ${aws_instance.vms["vm-k8s-worker-02"].private_ip}
    ${aws_instance.vms["vm-k8s-worker-03"].private_ip}
  INI
}
