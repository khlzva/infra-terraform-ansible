terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  token     = "token"
  cloud_id  = "cloud_id"
  folder_id = "folder_id"
  zone      = "ru-central1"
}

resource "yandex_compute_instance" "bastion" {
  name = "bastion"
  zone = "ru-central1-a"
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = "image_id"
      size = 4
    }
  }
  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet-1.id
    ip_address = "192.168.10.101"
    nat        = true
  }
  metadata = {
    user-data = "${file("./meta.yaml")}"
  }
}

resource "yandex_compute_instance" "web1" {
  name = "web1"
  zone = "ru-central1-a"
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = "image_id"
      size = 4
    }
  }
  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet-2.id
    ip_address = "192.168.11.101"
  }
  metadata = {
    user-data = "${file("./meta.yaml")}"
  }
}

resource "yandex_compute_instance" "web2" {
  name = "web2"
  zone = "ru-central1-b"
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = "image_id"
      size = 4
    }
  }
  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet-3.id
    ip_address = "192.168.12.101"
  }
  metadata = {
    user-data = "${file("./meta.yaml")}"
  }
}

resource "yandex_compute_instance" "prometheus" {
  name = "prometheus"
  zone = "ru-central1-a"
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = "image_id"
      size = 4
    }
  }
  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet-2.id
    ip_address = "192.168.11.102"
  }
  metadata = {
    user-data = "${file("./meta.yaml")}"
  }
}

resource "yandex_compute_instance" "grafana" {
  name = "grafana"
  zone = "ru-central1-a"
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = "image_id"
      size = 4
    }
  }
  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet-1.id
    ip_address = "192.168.10.102"
    nat        = true
  }
  metadata = {
    user-data = "${file("./meta.yaml")}"
  }
}

resource "yandex_compute_instance" "elasticsearch" {
  name = "elasticsearch"
  zone = "ru-central1-a"
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = "image_id"
      size = 8
    }
  }
  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet-2.id
    ip_address = "192.168.11.103"
  }
  metadata = {
    user-data = "${file("./meta.yaml")}"
  }
}

resource "yandex_compute_instance" "kibana" {
  name = "kibana"
  zone = "ru-central1-a"
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = "image_id"
      size = 8
    }
  }
  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet-1.id
    ip_address = "192.168.10.103"
    nat        = true
  }
  metadata = {
    user-data = "${file("./meta.yaml")}"
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "subnet-2" {
  name           = "subnet2"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.11.0/24"]
}

resource "yandex_vpc_subnet" "subnet-3" {
  name           = "subnet3"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.12.0/24"]
}

resource "yandex_vpc_security_group" "infra_security_group" {
  name        = "Infrastructure security group"
  network_id  = "${yandex_vpc_network.network-1.id}"

  ingress {
    protocol       = "TCP"
    description    = "NGINX"
    v4_cidr_blocks = ["192.168.11.101/32", "192.168.12.101/32"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.11.0/24", "192.168.12.0/24"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "Prometheus"
    v4_cidr_blocks = ["192.168.11.102/32"]
    port           = 9090
  }

  ingress {
    protocol       = "TCP"
    description    = "Node Exporter"
    v4_cidr_blocks = ["192.168.11.102/32"]
    port           = 9100
  }

  ingress {
    protocol       = "TCP"
    description    = "Nginx Log Exporter"
    v4_cidr_blocks = ["192.168.11.102/32"]
    port           = 4040
  }

  ingress {
    protocol       = "TCP"
    description    = "Grafana"
    v4_cidr_blocks = ["192.168.10.102/32"]
    port           = 3000
  }

  ingress {
    protocol       = "TCP"
    description    = "Kiabna"
    v4_cidr_blocks = ["192.168.10.103/32"]
    port           = 5601
  }

  ingress {
    protocol       = "ICMP"
    description    = "ICMP"
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.11.0/24", "192.168.12.0/24"]
  }

  egress {
    protocol       = "ANY"
    description    = "Egress rule"
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.11.0/24", "192.168.12.0/24"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_alb_target_group" "web-target-group" {
  name      = "web-target-group"
  target {
    subnet_id  = "${yandex_vpc_subnet.subnet-2.id}"
    ip_address = "${yandex_compute_instance.web1.network_interface.0.ip_address}"
  }
  target {
    subnet_id  = "${yandex_vpc_subnet.subnet-3.id}"
    ip_address = "${yandex_compute_instance.web2.network_interface.0.ip_address}"
  }
}

resource "yandex_alb_backend_group" "web-backend-group" {
  name      = "web-backend-group"
  http_backend {
    name   = "http-backend"
    weight = 1
    port   = 80
    target_group_ids = ["${yandex_alb_target_group.web-target-group.id}"]
    load_balancing_config {
      panic_threshold = 50
    }    
    healthcheck {
      timeout  = "1s"
      interval = "5s"
      http_healthcheck {
        path  = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "http-router" {
  name      = "http-router"
}

resource "yandex_alb_virtual_host" "virtual-host" {
  name      = "virtual-host"
  http_router_id = yandex_alb_http_router.http-router.id
  route {
    name = "route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web-backend-group.id
        timeout = "3s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "load-balancer" {
  name        = "load-balancer"
  network_id  = yandex_vpc_network.network-1.id
  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnet-1.id 
    }
  }
  listener {
    name = "listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }    
    http {
      handler {
        http_router_id = yandex_alb_http_router.http-router.id
      }
    }
  }    
}

output "internal_ip_address_bastion" {
  value = yandex_compute_instance.bastion.network_interface.0.ip_address
}
output "external_ip_address_bastion" {
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}

output "internal_ip_address_web1" {
  value = yandex_compute_instance.web1.network_interface.0.ip_address
}
output "internal_ip_address_web2" {
  value = yandex_compute_instance.web2.network_interface.0.ip_address
}

output "internal_ip_address_prometheus" {
  value = yandex_compute_instance.prometheus.network_interface.0.ip_address
}

output "internal_ip_address_grafana" {
  value = yandex_compute_instance.grafana.network_interface.0.ip_address
}
output "external_ip_address_grafana" {
  value = yandex_compute_instance.grafana.network_interface.0.nat_ip_address
}

output "internal_ip_address_elasticsearch" {
  value = yandex_compute_instance.elasticsearch.network_interface.0.ip_address
}

output "internal_ip_address_kibana" {
  value = yandex_compute_instance.kibana.network_interface.0.ip_address
}
output "external_ip_address_kibana" {
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}
