# ============================================================
# General
# ============================================================

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-central-1"
}

variable "project" {
  description = "Project name — used for resource names and tags"
  type        = string
  default     = "homelab"
}

variable "key_pair_name" {
  description = "Name of the EC2 Key Pair for SSH access"
  type        = string
  default     = "homelab-key"
}

# ============================================================
# Networking
# ============================================================

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable "subnet_cidrs" {
  description = "CIDR blocks per network zone"
  type        = map(string)
  default = {
    public     = "192.168.20.0/24"
    management = "192.168.10.0/24"
    internal   = "192.168.30.0/24"
    kubernetes = "192.168.40.0/24"
  }
}

# ============================================================
# Virtual Machines
# ============================================================

variable "vms" {
  description = "VM definitions — one entry per EC2 instance"
  type = map(object({
    instance_type = string # EC2 instance type, e.g. t3.micro
    subnet        = string # must match a key in subnet_cidrs
    private_ip    = string # static private IP within the subnet
    public_ip     = bool   # true only for VMs in the public subnet
  }))
}
