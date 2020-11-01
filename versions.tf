terraform {
  required_providers {
    proxmox = {
      source = "terraform.ecnc.link/danitso/proxmox"
      version = ">= 0.3.0"
    }
  }
  required_version = ">= 0.13"
}
