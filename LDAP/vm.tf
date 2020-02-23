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

resource "google_compute_instance" "ldap-server" {
  name         = "server"
  project     = "${var.project_name}"
  machine_type = "custom-1-4608"
  zone         = "${var.zone}"
  tags = "${var.tags}"
  depends_on    = ["google_compute_subnetwork.public-subnet"]

  boot_disk {
    initialize_params {
      image = "${var.image}"
      size = "${var.size}"
      type = "pd-ssd"
    } 
  }

 network_interface {
  subnetwork = "${google_compute_subnetwork.public-subnet.self_link}"
  network_ip = "10.13.1.13"
  access_config {}
  }
 
 metadata {
    startup_script = "${file("script.sh")}"  
    }
 }


resource "google_compute_instance" "ldap-client" {
  name         = "client"
  project     = "${var.project_name}"
  machine_type = "custom-1-4608"
  zone         = "${var.zone}"
  tags = "${var.tags}"
  depends_on    = ["google_compute_subnetwork.public-subnet"]

  boot_disk {
    initialize_params {
      image = "${var.image}"
      size = "${var.size}"
      type = "pd-ssd"
    } 
  }

 network_interface {
  subnetwork = "${google_compute_subnetwork.public-subnet.self_link}"
  network_ip = "10.13.1.14"
  access_config {}
  }
 
 metadata {
    startup_script = "${file("clientscript.sh")}"  
    }
 }