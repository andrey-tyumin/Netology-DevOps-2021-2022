terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
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

provider "yandex" {
  token = "${var.token}"
  cloud_id = "b1gcrs80g9fbsog56an7"
  folder_id = "b1g7gtkhdrrn4qpc2l2t"
  zone = "ru-central1-a"
}


  resource yandex_compute_instance  "teamcity-server" {
  name="teamcity-server"
  resources {
    cores = 4
    memory = 8
	}

  boot_disk {
    initialize_params {
      image_id = "fd8r8r553k5teebhktos"
      size = "30"
	 }
	}

  metadata = {
    user-data = "${file("./metadata.txt")}"
    docker-container-declaration = "${file("./teamcity-server.yaml")}"
  }
  
  network_interface {
    subnet_id = "e9bjh4umf8fkvpsk068p"
    nat = true
	}
  }

data "local_file" "SendURL" {
 filename = "./teamcity-agent.tmpl"
 depends_on = [yandex_compute_instance.teamcity-server]
}

data "template_file" "input" {
  template = data.local_file.SendURL.content
  vars = {
    teamcity-server-ip = yandex_compute_instance.teamcity-server.network_interface.0.nat_ip_address
  }
}

resource yandex_compute_instance  "teamcity-agent" {
  name="teamcity-agent"
  resources {
    cores = 2
    memory = 8
	}

  boot_disk {
    initialize_params {
      image_id = "fd8r8r553k5teebhktos"
      size = "30"
	 }
	}

  metadata = {
    user-data = "${file("./metadata.txt")}"
    docker-container-declaration = data.template_file.input.rendered
  }
  
  network_interface {
    subnet_id = "e9bjh4umf8fkvpsk068p"
    nat = true
	}
  depends_on = [yandex_compute_instance.teamcity-server]
  }


resource yandex_compute_instance  "nexus" {
name="nexus"
  resources {
    cores = 2
    memory = 4
        }

  boot_disk {
    initialize_params {
      image_id = "fd8u8t05uet8frke86tb"
      size = "30"
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

output "teamcity-server" {
value = yandex_compute_instance.teamcity-server.network_interface.0.nat_ip_address
}
output "teamcity-agent" {
value = yandex_compute_instance.teamcity-agent.network_interface.0.nat_ip_address
}
output "nexus" {
value = yandex_compute_instance.nexus.network_interface.0.nat_ip_address
}

resource "local_file" "AnsibleInventory" {
 content = templatefile("inventory.tmpl",
 {
  teamcity-server-ip = yandex_compute_instance.teamcity-server.network_interface.0.nat_ip_address,
  teamcity-agent-ip = yandex_compute_instance.teamcity-agent.network_interface.0.nat_ip_address
  nexus-ip = yandex_compute_instance.nexus.network_interface.0.nat_ip_address
    }
 )
 filename = "./infrastructure/inventory/cicd/hosts.yml"
}
