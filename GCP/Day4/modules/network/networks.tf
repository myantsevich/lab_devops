resource "google_compute_network" "vpc_network" {
  name          = "${var.name}-vpc"
  project       = "${var.project_name}"
  auto_create_subnetworks = false
  routing_mode  = "GLOBAL"
}

resource "google_compute_subnetwork" "private-subnet" {
  name          = "${var.name}-private-subnet"
  ip_cidr_range = "10.13.2.0/24"
  region        = "${var.region}"
  network       = "${var.name}-vpc"
  depends_on    = ["google_compute_network.vpc_network"]
  private_ip_google_access = "true"
}

resource "google_compute_subnetwork" "public-subnet" {
  name          = "${var.name}-public-subnet"
  ip_cidr_range = "10.13.1.0/24"
  region        = "${var.region}"
  network       = "${var.name}-vpc"
  depends_on    = ["google_compute_network.vpc_network"]
}

# resource "google_compute_firewall" "allow-internal" {
#   name          = "allowint"
#   network       = "${google_compute_network.vpc_network.name}"
  
#   allow {
#     protocol    = "tcp"
#     ports       = ["0-65535"]
#   }
#   direction     = "EGRESS"
# }

resource "google_compute_firewall" "allow-http" {
  name          = "allowhttp"
  network       = "${google_compute_network.vpc_network.name}"

  allow {
    protocol    = "tcp"
    ports       = ["80"]
  }

  target_tags   = ["http-server"] 
}

resource "google_compute_firewall" "allow-ssh" {
  name          = "allowssh"
  network       = "${google_compute_network.vpc_network.name}"

  allow {
    protocol    = "tcp"
    ports       = ["22"]
  }

  target_tags   = ["ssh"]
}

output "vpc" {
  value = "${google_compute_network.vpc_network.name}"
}
output "priv-sub" {
  value = "${google_compute_subnetwork.private-subnet.name}"
}
output "pub-sub" {
  value = "${google_compute_subnetwork.public-subnet.name}"
}

