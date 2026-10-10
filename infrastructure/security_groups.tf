# ============================================================
# Public zone — bastion, proxy, CA
# ============================================================

resource "aws_security_group" "public" {
  name        = "${var.project}-sg-public"
  description = "Public zone: bastion, proxy, CA"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from internet (bastion)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet (proxy)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from internet (redirect to HTTPS)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "step-ca ACME from internal VMs and Kubernetes"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-sg-public" }
}

# ============================================================
# Management zone — dns, storage
# ============================================================

resource "aws_security_group" "management" {
  name        = "${var.project}-sg-management"
  description = "Management zone: dns, storage"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.subnet_cidrs["public"]]
  }

  ingress {
    description = "All traffic within management zone"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.subnet_cidrs["management"]]
  }

  ingress {
    description = "DNS UDP from all zones"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["192.168.0.0/16"]
  }

  ingress {
    description = "DNS TCP from all zones"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/16"]
  }

  ingress {
    description = "NFS from kubernetes zone"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.subnet_cidrs["kubernetes"]]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-sg-management" }
}

# ============================================================
# Internal zone — vault, gitlab, db, keycloak
# ============================================================

resource "aws_security_group" "internal" {
  name        = "${var.project}-sg-internal"
  description = "Internal zone: vault, gitlab, db, keycloak"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from bastion and Ansible from management"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.subnet_cidrs["public"], var.subnet_cidrs["management"]]
  }

  ingress {
    description = "HTTP/HTTPS from proxy"
    from_port   = 80
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.subnet_cidrs["public"]]
  }

  ingress {
    description = "All traffic within internal zone"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.subnet_cidrs["internal"]]
  }

  ingress {
    description = "All traffic from kubernetes zone (ESO, pods)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.subnet_cidrs["kubernetes"]]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-sg-internal" }
}

# ============================================================
# Kubernetes zone — masters and workers
# ============================================================

resource "aws_security_group" "kubernetes" {
  name        = "${var.project}-sg-kubernetes"
  description = "Kubernetes zone: masters and workers"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.subnet_cidrs["public"]]
  }

  ingress {
    description = "kubectl API from bastion and management"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.subnet_cidrs["public"], var.subnet_cidrs["management"]]
  }

  ingress {
    description = "All traffic from internal zone"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.subnet_cidrs["internal"]]
  }

  ingress {
    description = "All traffic within kubernetes zone (node-to-node)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.subnet_cidrs["kubernetes"]]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-sg-kubernetes" }
}
