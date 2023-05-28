terraform {
	required_providers {
	  yandex = {
	    source="terraform-registry.storage.yandexcloud.net/yandex-cloud/yandex"
		   }
	  null = {
	    source = "terraform-registry.storage.yandexcloud.net/hashicorp/null"			}
		}
}

provider "yandex" {
	token="${var.token}"
	folder_id="${var.folderid}"
        zone="${var.zoneid}"
	cloud_id="${var.cloudid}"
}
#Create network
resource "yandex_vpc_network" "hw151" {
	name = "hw151-net"
}
#Create public subnet
resource "yandex_vpc_subnet" "hw151-public-subnet" {
    name="public"
	v4_cidr_blocks=["192.168.10.0/24"]
	zone="ru-central1-a"
	network_id="${yandex_vpc_network.hw151.id}"
	depends_on = [yandex_resourcemanager_folder_iam_member.sa-ig-editor]
}
#Create nat in public subnet
resource yandex_compute_instance "hw151-nat" {
	name="nat"
	resources {
	cores=2
	memory=2
	}

	boot_disk {
	initialize_params {
    image_id="fd80mrhj8fl2oe87o4e1"
		}
	}

	metadata={
	user-data="${file("./metadata.txt")}"
	}

	network_interface {
	subnet_id="${yandex_vpc_subnet.hw151-public-subnet.id}"
	ip_address="192.168.10.254"
	nat=true
	}
}
#Create vm1 in public subnet
resource yandex_compute_instance "VM1" {
	name="vm1"
	resources {
	cores=2
	memory=2
	}

	boot_disk {
	initialize_params {
	image_id="fd879gb88170to70d38a"
		}
	}

	metadata={
	user-data="${file("./metadata.txt")}"
	}

	network_interface {
	subnet_id="${yandex_vpc_subnet.hw151-public-subnet.id}"
	nat=true
	}
}
#Create route from private subnet to nat
resource yandex_vpc_route_table "hw151-private-nat" {
	network_id="${yandex_vpc_network.hw151.id}"

	static_route {
	destination_prefix="0.0.0.0/0"
	next_hop_address="192.168.10.254"
	}
}
#Create private subnet
resource yandex_vpc_subnet "hw151-private-subnet" {
	name="private"
	v4_cidr_blocks=["192.168.20.0/24"]
	zone="ru-central1-a"
	network_id="${yandex_vpc_network.hw151.id}"
        route_table_id="${yandex_vpc_route_table.hw151-private-nat.id}"
}
#Create vm2 in private subnet
resource yandex_compute_instance "VM2" {
	name="vm2"
	resources {
	cores=2
	memory=2
	}

	boot_disk {
	initialize_params {
	image_id="fd879gb88170to70d38a"
		}
	}

	metadata={
	user-data="${file("./metadata.txt")}"
	}

	network_interface {
	subnet_id="${yandex_vpc_subnet.hw151-private-subnet.id}"
	}
}
#Create service account
resource "yandex_iam_service_account" "hw152-sa" {
  folder_id = "${var.folderid}"
  name      = "hw152-sa"
}

#Add persmission to service account
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = "${var.folderid}"
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.hw152-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-ig-editor" {
  folder_id = "${var.folderid}"
  role = "editor"
  member = "serviceAccount:${yandex_iam_service_account.hw152-sa.id}"
}

#Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "hw152-sa-static-key" {
  service_account_id = "${yandex_iam_service_account.hw152-sa.id}"
  description = "static access key for hw152-sa"
}

#create bucket
resource "yandex_storage_bucket" "hw152-bucket" {
  access_key = "${yandex_iam_service_account_static_access_key.hw152-sa-static-key.access_key}"
  secret_key = "${yandex_iam_service_account_static_access_key.hw152-sa-static-key.secret_key}"
  bucket = "hw152-bucket"
  acl    = "public-read"
}

#download picture
resource "null_resource" "download-pict" {
	provisioner "local-exec" {
	command = "wget https://u.netology.ngcdn.ru/tilda/uploads/images/main.svg -O ./picture.svg"
	}
}

#upload picture to bucket
resource "yandex_storage_object" "hw152-object" {
  access_key = "${yandex_iam_service_account_static_access_key.hw152-sa-static-key.access_key}"
  secret_key = "${yandex_iam_service_account_static_access_key.hw152-sa-static-key.secret_key}"
  bucket = "${yandex_storage_bucket.hw152-bucket.id}"
  key    = "picture.svg"
  source = "./picture.svg"
}
#Create instance group
resource "yandex_compute_instance_group" "hw152-ig" {
  name = "hw152-ig"
  folder_id = "${var.folderid}"
  service_account_id = "${yandex_iam_service_account.hw152-sa.id}"
  depends_on = [yandex_resourcemanager_folder_iam_member.sa-ig-editor]

  instance_template {
    resources {
      memory =2
      cores = 2
      }
    boot_disk {
      initialize_params {
        image_id = "fd827b91d99psvq5fjit"
        }
      }
    network_interface {
    network_id = "${yandex_vpc_network.hw151.id}"
    subnet_ids = ["${yandex_vpc_subnet.hw151-public-subnet.id}"]
	  nat=true
    }
    labels = {
      label1 = "nginx"
      label2 = "hw152"
    }
    metadata = {
      user-data = "${file("./metadata.txt")}"
      user-data = "${file("logo.sh")}"
    }

  }

	health_check {
    interval = 30
    timeout = 15
    healthy_threshold = 2
    unhealthy_threshold = 3
    tcp_options { port = 80}
  }
  scale_policy {
	  fixed_scale {
	  size = 3
	  }
  	}
  
  allocation_policy {
    zones = ["${var.zoneid}"]
  }
	
  deploy_policy {
	  max_unavailable = 2
	  max_deleting = 1
    max_expansion = 1
	  }

  load_balancer {
	  target_group_name = "hw152-load-balancer"
	  target_group_description = "Network balancer for intance group hw152-ig"
  }
}

#create loadbalancer
resource "yandex_lb_network_load_balancer" "lb152" {
  name = "lb152"

  listener {
    name = "uhi"
    port = 80
    target_port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = "${yandex_compute_instance_group.hw152-ig.load_balancer.0.target_group_id}"
    healthcheck {
      name = "tcp"
      interval = 30
      tcp_options {
        port = 80
      }
    }
  }
depends_on=[yandex_compute_instance_group.hw152-ig]
}
#Get ip for output
data "yandex_lb_network_load_balancer" "lb152" {
   network_load_balancer_id = "${yandex_lb_network_load_balancer.lb152.id}"
 }