terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.68.0"
    }
  }
}

variable "token" {
  type = string
}

provider "yandex" {
  token = "${var.token}"
  cloud_id = "b1gcrs80g9fbsog56an7"
  folder_id = "b1g7gtkhdrrn4qpc2l2t"
  zone = "ru-central1-a"
}


  resource yandex_compute_instance  "nicemech" {
  for_each=toset(["redis1", "redis2", "redis3"])
  name=each.key

  resources {
    cores = 2
    memory = 4
	}

  boot_disk {
    initialize_params {
      image_id = "fd8u8t05uet8frke86tb"
      size = "20"
	 }
	}

  metadata = {
    user-data = "${file("./metadata.txt")}"
	}
  
  network_interface {
    subnet_id = "e9bjh4umf8fkvpsk068p"
    nat = true
	}
  }

output "redis1_ip" {
value = yandex_compute_instance.nicemech["redis1"].network_interface.0.nat_ip_address
}
output "redis2_ip" {
value = yandex_compute_instance.nicemech["redis2"].network_interface.0.nat_ip_address
}
output "redis3_ip" {
value = yandex_compute_instance.nicemech["redis3"].network_interface.0.nat_ip_address
}

resource "local_file" "AnsibleInventory" {
 content = templatefile("inventory.tmpl",
 {
  redis1-ip = yandex_compute_instance.nicemech["redis1"].network_interface.0.nat_ip_address,
  redis2-ip = yandex_compute_instance.nicemech["redis2"].network_interface.0.nat_ip_address,
  redis3-ip = yandex_compute_instance.nicemech["redis3"].network_interface.0.nat_ip_address
  }
 )
 filename = "./hosts.yml"
}
