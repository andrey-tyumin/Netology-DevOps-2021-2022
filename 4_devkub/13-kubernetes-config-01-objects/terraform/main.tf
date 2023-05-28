terraform {
  required_providers {
    yandex ={
      source= "yandex-cloud/yandex"
      version = "0.61.0"
      }
    }
  }

data "yandex_compute_image" "container-optimized-image" {
  family = "container-optimized-image"
}

variable "token" {
  type = string
  }

variable "cloudid" {
  type = string
  default = "b1gcrs80g9fbsog56an7"
  }

variable "folderid" {
  type = string
  default = "b1g7gtkhdrrn4qpc2l2t"
  }

variable "zoneid" {
  type = string
  default = "ru-central1-a"
  }

variable "imageid" {
  description = "image for provisioning"
  type = string
  default = "fd8u8t05uet8frke86tb"
  }

variable "subnetid" {
  type = string
  default = "e9bjh4umf8fkvpsk068p"
  }

provider "yandex" {
  token = "${var.token}"
  cloud_id = "${var.cloudid}"
  folder_id = "${var.folderid}"
  zone = "${var.zoneid}"
  }

  resource yandex_compute_instance  "nfs-server" {
  name="nfs-server"
  resources {
    cores = 2
    memory = 4
	}

  boot_disk {
    initialize_params {
      image_id = "fd8r8r553k5teebhktos"
      size = "30"
	 }
	}

  metadata = {
    user-data = "${file("./metadata.txt")}"
    docker-container-declaration = "${file("./nfs-server.yaml")}"
  }
  
  network_interface {
    subnet_id = "e9bjh4umf8fkvpsk068p"
    nat = true
	}
  }

resource yandex_compute_instance "cp"{
name = "cp"
resources {
  cores = 4
  memory = 4
  }

boot_disk {
  initialize_params {
    image_id = "${var.imageid}"
    size = "50"
    }
  }

metadata = {
  user-data = "${file("./metadata.txt")}"
  }

network_interface {
  subnet_id = "${var.subnetid}"
  nat = true
  }
}
resource yandex_compute_instance "worknode"{
for_each=toset(["node1","node2","node3","node4"])
name=each.key

resources {
  cores=2
  memory=2
  }

boot_disk {
  initialize_params {
    image_id = "${var.imageid}"
    size=80
    }
  }

metadata = {
  user-data = "${file("./metadata.txt")}"
  }

network_interface {
  subnet_id ="${var.subnetid}"
  nat = true
  }
depends_on=[yandex_compute_instance.cp]
 }

resource "yandex_lb_target_group" "hw131-lb-tg" {
  name      = "hw131-lb-tg"
  region_id = "ru-central1"

  target {
    subnet_id = "${var.subnetid}"
    address   = "${yandex_compute_instance.worknode["node1"].network_interface.0.ip_address}"
  }

  target {
    subnet_id = "${var.subnetid}"
    address   = "${yandex_compute_instance.worknode["node2"].network_interface.0.ip_address}"
  }

   target {
    subnet_id = "${var.subnetid}"
    address   = "${yandex_compute_instance.worknode["node3"].network_interface.0.ip_address}"
  }

   target {
    subnet_id = "${var.subnetid}"
    address   = "${yandex_compute_instance.worknode["node4"].network_interface.0.ip_address}"
  }
depends_on=[yandex_compute_instance.worknode]
}


resource "yandex_lb_network_load_balancer" "lb131" {
  name = "lb131"

  listener {
    name = "banderlog"
    port = 80
    target_port = 30080
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = "${yandex_lb_target_group.hw131-lb-tg.id}"
    healthcheck {
      name = "tcp"
      interval = 30
      tcp_options {
        port = 30080
      }
    }
  }
depends_on=[yandex_lb_target_group.hw131-lb-tg]
}

output "nfs-server" {
value = yandex_compute_instance.nfs-server.network_interface.0.ip_address
}

output "cp" {
value = yandex_compute_instance.cp.network_interface.0.nat_ip_address
}
output "cp_internal_address" {
value = yandex_compute_instance.cp.network_interface.0.ip_address
}

output "node1" {
value = yandex_compute_instance.worknode["node1"].network_interface.0.nat_ip_address
}
output "node1_internal_address" {
value = yandex_compute_instance.worknode["node1"].network_interface.0.ip_address
}

output "node2" {
value = yandex_compute_instance.worknode["node2"].network_interface.0.nat_ip_address
}
output "node2_internal_address" {
value = yandex_compute_instance.worknode["node2"].network_interface.0.ip_address
}

output "node3" {
value = yandex_compute_instance.worknode["node3"].network_interface.0.nat_ip_address
}
output "node3_internal_address" {
value = yandex_compute_instance.worknode["node3"].network_interface.0.ip_address
}

output "node4" {
value = yandex_compute_instance.worknode["node4"].network_interface.0.nat_ip_address
}
output "node4_internal_address" {
value = yandex_compute_instance.worknode["node4"].network_interface.0.ip_address
}

resource "local_file" "Create_inventory" {
content = templatefile("inventory.tmpl",
{
cp = yandex_compute_instance.cp.network_interface.0.nat_ip_address
cp_internal_address = yandex_compute_instance.cp.network_interface.0.ip_address
node1= yandex_compute_instance.worknode["node1"].network_interface.0.nat_ip_address
node1_internal_address = yandex_compute_instance.worknode["node1"].network_interface.0.ip_address
node2 = yandex_compute_instance.worknode["node2"].network_interface.0.nat_ip_address
node2_internal_address = yandex_compute_instance.worknode["node2"].network_interface.0.ip_address
node3 = yandex_compute_instance.worknode["node3"].network_interface.0.nat_ip_address
node3_internal_address = yandex_compute_instance.worknode["node3"].network_interface.0.ip_address
node4 = yandex_compute_instance.worknode["node4"].network_interface.0.nat_ip_address
node4_internal_address = yandex_compute_instance.worknode["node4"].network_interface.0.ip_address
}
)
filename = "./inventory.ini"
}
