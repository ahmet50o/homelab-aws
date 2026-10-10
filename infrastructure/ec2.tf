# ============================================================
# AMI — latest Ubuntu 24.04 LTS in eu-central-1
# ============================================================

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical official account

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ============================================================
# cloud-init user-data template
# ============================================================

locals {
  cloud_init = templatefile("${path.module}/cloud-init.yaml.tpl", {
    ssh_public_key = file("~/.ssh/homelab.pub")
    dns_server     = "192.168.10.12" # vm-dns static IP
  })
}

# ============================================================
# Security group mapping — which zone gets which SG
# ============================================================

locals {
  sg_map = {
    public     = aws_security_group.public.id
    management = aws_security_group.management.id
    internal   = aws_security_group.internal.id
    kubernetes = aws_security_group.kubernetes.id
  }
}

# ============================================================
# EC2 instances
# ============================================================

resource "aws_instance" "vms" {
  for_each = var.vms

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = each.value.instance_type
  key_name               = var.key_pair_name
  subnet_id              = aws_subnet.zones[each.value.subnet].id
  vpc_security_group_ids = [local.sg_map[each.value.subnet]]
  private_ip             = each.value.private_ip

  associate_public_ip_address = each.value.public_ip

  user_data = local.cloud_init

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = each.key
    Role = each.key
  }
}

# ============================================================
# Elastic IP for bastion (static public IP)
# ============================================================

resource "aws_eip" "bastion" {
  instance = aws_instance.vms["vm-bastion"].id
  domain   = "vpc"

  tags = {
    Name = "${var.project}-bastion-eip"
  }
}
