terraform {
  required_providers {
    yandex ={
      source= "yandex-cloud/yandex"
      version = "0.61.0"
      }
    }
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
    size=100
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
