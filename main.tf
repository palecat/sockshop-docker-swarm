terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.74.0"
    }
  }
}

provider "yandex" {
  token     = "<your token>"
  cloud_id  = "<your cloud_id>"
  folder_id = "<your folder_id>"
  zone      = "ru-central1-a"
}

resource "yandex_vpc_network" "network" {
  name = "swarm-network"
}

resource "yandex_vpc_subnet" "subnet" {
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
}

module "swarm_cluster" {
  source        = "./modules/instance"
  vpc_subnet_id = yandex_vpc_subnet.subnet.id
  managers      = 3
  workers       = 3
}
