provider "proxmox" {
  virtual_environment {
    endpoint = "$PROXMOX_VE_ENDPOINT"
    insecure = true
    username = "$PROXMOX_VE_USERNAME"
    password = "$PROXMOX_VE_USERNAME"
  }
}

resource "proxmox_virtual_environment_file" "mirrors_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name = "$ECNC_MIRRORS_NODE"

  source_file {
    path = "https://mirrors.tuna.tsinghua.edu.cn/ubuntu-cloud-images/server/focal/current/focal-server-cloudimg-amd64.img"
  }
}

resource "proxmox_virtual_environment_file" "mirrors_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "$ECNC_MIRRORS_NODE"

  source_raw {
    filename = "mirrors_cloud_init.conf"
    data = file("mirrors_cloud_init.conf")
  }
}

resource "proxmox_virtual_environment_vm" "mirrors_vm" {
  name        = "ecnc-mirrors"
  description = "ECNC Mirrors VM, Managed by Terraform"

  node_name = "$ECNC_MIRRORS_NODE"
  vm_id     = 200

  agent {
    enabled = true
  }

  cpu {
    cores = 24
    type = "host"
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = "${proxmox_virtual_environment_file.mirrors_cloud_image.id}"
    size         = 40
  }

  initialization {
    dns {
      server = "10.8.8.8 10.8.4.4"
    }
    ip_config {
      ipv4 {
        address = "222.200.161.1/24"
        gateway = "222.200.161.254"
      }
      ipv6 {
        address = "dhcp"
      }
    }

    user_data_file_id = "${proxmox_virtual_environment_file.mirrors_cloud_config.id}"
  }

  memory {
    dedicated = 16384
    floating = 16384
  }

  network_device {
    bridge = "vmbr1"
    model = "virtio"
  }

  operating_system {
    type = "l26"
  }

  serial_device {
    device = "socket"
  }

  vga {
    type = "serial0"
  }
}
