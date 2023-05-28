terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.61.0"
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
  for_each=toset(["elasticsearch", "kibana", "filebeat"])
  name=each.key

  resources {
    cores = 2
    memory = 2
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

output "kibana_ip" {
value = yandex_compute_instance.nicemech["kibana"].network_interface.0.nat_ip_address
}
output "elasticsearch_ip" {
value = yandex_compute_instance.nicemech["elasticsearch"].network_interface.0.nat_ip_address
}
output "filebeat_ip" {
value = yandex_compute_instance.nicemech["filebeat"].network_interface.0.nat_ip_address
}

resource "local_file" "AnsibleInventory" {
 content = templatefile("inventory.tmpl",
 {
  kibana-ip = yandex_compute_instance.nicemech["kibana"].network_interface.0.nat_ip_address,
  elasticsearch-ip = yandex_compute_instance.nicemech["elasticsearch"].network_interface.0.nat_ip_address,
  filebeat-ip = yandex_compute_instance.nicemech["filebeat"].network_interface.0.nat_ip_address
  }
 )
 filename = "./hosts.yml"
}
