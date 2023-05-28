terraform {
	required_providers {
	  yandex = {
	    source="terraform-registry.storage.yandexcloud.net/yandex-cloud/yandex"
	  }
	}
}

provider "yandex" {
	token="${var.token}"
	folder_id="${var.folderid}"
	zone="${var.zoneid}"
	cloud_id="${var.cloudid}"
}

resource "yandex_vpc_network" "hw151" {
	name = "hw151-net"
}

resource "yandex_vpc_subnet" "hw151-public-subnet" {
    name="public"
	v4_cidr_blocks=["192.168.10.0/24"]
	zone="ru-central1-a"
	network_id="${yandex_vpc_network.hw151.id}"
}

resource yandex_compute_instance "hw151-nat" {
	name="nat"
	resources {
	cores=2
	memory=2
	}

	boot_disk {
	initialize_params {
#	image_id="fd85vbr6kin3r8ro2e95"
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

resource yandex_vpc_route_table "hw151-private-nat" {
	network_id="${yandex_vpc_network.hw151.id}"

	static_route {
	destination_prefix="0.0.0.0/0"
	next_hop_address="192.168.10.254"
	}
}

resource yandex_vpc_subnet "hw151-private-subnet" {
	name="private"
	v4_cidr_blocks=["192.168.20.0/24"]
	zone="ru-central1-a"
	network_id="${yandex_vpc_network.hw151.id}"
        route_table_id="${yandex_vpc_route_table.hw151-private-nat.id}"
}


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
