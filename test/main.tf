terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.2"
    }
  }
}

provider "libvirt" {
  alias = "vmhost01"
  uri   = "qemu+ssh://vmhost01/system"
}

variable "env" {
  type = string
}

resource "libvirt_volume" "nginx" {
  provider         = libvirt.vmhost01
  name             = "nginx-${var.env}.qcow2"
  pool             = var.env
  base_volume_name = "nginx_base.qcow2"
  format           = "qcow2"
  base_volume_pool = var.env
}

resource "libvirt_domain" "nginx" {
  provider  = libvirt.vmhost01
  name      = "nginx-${var.env}"
  memory    = "512"
  vcpu      = 1
  autostart = true

  // The MAC here is given an IP through mikrotik
  network_interface {
    macvtap  = "enp0s25"
    mac      = "52:54:00:EA:17:56"
    hostname = "nginx-${var.env}"
  }

  network_interface {
    // network_id = libvirt_network.default.id
    network_name = "default"
  }

  disk {
    volume_id = libvirt_volume.nginx.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = 0
  }

}
