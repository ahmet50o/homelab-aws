#cloud-config

# Create ansible user for configuration management
users:
  - name: ansible
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${ssh_public_key}

# Disable root SSH and password authentication
ssh_pwauth: false

# Set DNS server to vm-dns once it is running
# Until Phase 2 is complete, VMs use AWS default DNS
write_files:
  - path: /etc/systemd/resolved.conf.d/homelab.conf
    content: |
      [Resolve]
      DNS=${dns_server}
      Domains=homelab.local
    defer: true

packages:
  - curl
  - git
  - vim
  - htop
  - python3
  - python3-pip

package_update: true
