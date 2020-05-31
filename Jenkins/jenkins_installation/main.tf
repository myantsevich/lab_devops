provider "google" {
  credentials = "${file("./terraform-admin.json")}"
  project     = "${var.project}"
  region      = "${var.region}"
}

resource "google_compute_instance" "vm" {
  count         = "${var.instance_count}"
  name          = "vm-${count.index + 1}"
  project       = "${var.project}"
  machine_type  = "${var.type}"
  zone          = "${var.region}-a"
  depends_on    = ["google_compute_subnetwork.public-subnet"]

  boot_disk {
    initialize_params {
      image     = "myantsevich-packer"
      size      = "${var.size}"
      type      = "pd-ssd"
    } 
  }


  network_interface {
    subnetwork  = "${google_compute_subnetwork.public-subnet.name}"
    network_ip  = "10.13.1.2${count.index + 1}"
    access_config {}
  }
}

resource "google_compute_network" "vpc" {
  name          = "${var.name}-vpc"
  project       = "${var.project}"
  auto_create_subnetworks = false
  routing_mode  = "GLOBAL"
}

resource "google_compute_subnetwork" "public-subnet" {
  name          = "${var.name}-public-subnet"
  ip_cidr_range = "10.13.1.0/24"
  region        = "${var.region}"
  network       = "${var.name}-vpc"
  depends_on    = ["google_compute_network.vpc"]
}


resource "google_compute_firewall" "my-internal" {
  name          = "my-internal"
  network       = "${google_compute_network.vpc.name}"
  depends_on    = ["google_compute_network.vpc"]
  
  allow {
    protocol    = "tcp"
    ports       = ["0-65535"]
  }

  source_ranges  = [
    "10.13.1.0/24"
  ]
}

resource "google_compute_firewall" "my-vpc" {
  name          = "my-vpc"
  network       = "${google_compute_network.vpc.name}"
  depends_on    = ["google_compute_network.vpc"]

  allow {
    protocol    = "tcp"
    ports       = ["22", "8080", "80"]
  }

}

