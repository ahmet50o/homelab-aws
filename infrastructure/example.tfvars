aws_region    = "eu-central-1"
project       = "homelab"
key_pair_name = "homelab-key"

vpc_cidr = "192.168.0.0/16"

subnet_cidrs = {
  public     = "192.168.20.0/24"
  management = "192.168.10.0/24"
  internal   = "192.168.30.0/24"
  kubernetes = "192.168.40.0/24"
}

vms = {
  "vm-bastion" = {
    instance_type = "t3.micro"
    subnet        = "public"
    private_ip    = "192.168.20.10"
    public_ip     = true
  }
  "vm-ca" = {
    instance_type = "t3.micro"
    subnet        = "management"
    private_ip    = "192.168.10.11"
    public_ip     = false
  }
  "vm-proxy" = {
    instance_type = "t3.small"
    subnet        = "public"
    private_ip    = "192.168.20.12"
    public_ip     = true
  }

  "vm-dns" = {
    instance_type = "t3.micro"
    subnet        = "management"
    private_ip    = "192.168.10.12"
    public_ip     = false
  }
  "vm-storage" = {
    instance_type = "t3.small"
    subnet        = "management"
    private_ip    = "192.168.10.13"
    public_ip     = false
  }

  "vm-vault" = {
    instance_type = "t3.small"
    subnet        = "internal"
    private_ip    = "192.168.30.10"
    public_ip     = false
  }
  "vm-gitlab" = {
    instance_type = "t3.xlarge"
    subnet        = "internal"
    private_ip    = "192.168.30.11"
    public_ip     = false
  }
  "vm-db" = {
    instance_type = "t3.small"
    subnet        = "internal"
    private_ip    = "192.168.30.12"
    public_ip     = false
  }
  "vm-keycloak" = {
    instance_type = "t3.small"
    subnet        = "internal"
    private_ip    = "192.168.30.13"
    public_ip     = false
  }

  "vm-k8s-master" = {
    instance_type = "t3.small"
    subnet        = "kubernetes"
    private_ip    = "192.168.40.10"
    public_ip     = false
  }
  "vm-k8s-worker-01" = {
    instance_type = "t3.medium"
    subnet        = "kubernetes"
    private_ip    = "192.168.40.20"
    public_ip     = false
  }
  "vm-k8s-worker-02" = {
    instance_type = "t3.medium"
    subnet        = "kubernetes"
    private_ip    = "192.168.40.21"
    public_ip     = false
  }
  "vm-k8s-worker-03" = {
    instance_type = "t3.medium"
    subnet        = "kubernetes"
    private_ip    = "192.168.40.22"
    public_ip     = false
  }
}
