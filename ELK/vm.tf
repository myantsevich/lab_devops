resource "google_compute_network" "vpc" {
  name          = "vpc"
  project       = "${var.project_name}"
  auto_create_subnetworks = false
  routing_mode  = "GLOBAL"
}

resource "google_compute_subnetwork" "public-subnet" {
  name          = "public-subnet"
  ip_cidr_range = "10.13.1.0/24"
  region        = "${var.region}"
  network       = "vpc"
  depends_on    = ["google_compute_network.vpc"]
}

resource "google_compute_firewall" "allow-ports" {
  name          = "allow-ports"
  network       = "${google_compute_network.vpc.name}"
  depends_on    = ["google_compute_subnetwork.public-subnet"]

  allow {
    protocol    = "tcp"
    ports       = ["0-65535"]
  }
}

resource "google_compute_instance" "vm1" {
  name          = "vm1"
  project       = "${var.project_name}"
  machine_type  = "custom-1-4608"
  zone          = "${var.zone}"
  depends_on    = ["google_compute_subnetwork.public-subnet"]

  boot_disk {
    initialize_params {
      image = "${var.image}"
      size = "${var.size}"
      type = "pd-ssd"
    } 
  }

  network_interface {
  subnetwork = "${google_compute_subnetwork.public-subnet.name}"
  network_ip = "10.13.1.21"
  access_config {}
  }
 
  metadata_startup_script = "${file("./script.sh")}" 
  //startup-script-url = "https://storage.cloud.google.com/static-content-store-bucket/script.sh"

 }

resource "google_compute_instance" "vm2" {
  name         = "vm2"
  project      = "${var.project_name}"
  machine_type = "custom-1-4608"
  zone         = "${var.zone}"
  depends_on   = ["google_compute_subnetwork.public-subnet"]

  boot_disk {
    initialize_params {
      image = "${var.image}"
      size = "${var.size}"
      type = "pd-ssd"
    } 
  }

 network_interface {
  subnetwork = "${google_compute_subnetwork.public-subnet.name}"
  network_ip = "10.13.1.22"
  access_config {}
  }
 
  metadata_startup_script = "${file("./clientscript.sh")}"  

 }
