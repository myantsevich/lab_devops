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
    ports       = ["80", "389", "22"]
  }
}

resource "google_compute_instance" "ldap-server" {
  name          = "server"
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
  subnetwork = "${google_compute_subnetwork.public-subnet.self_link}"
  network_ip = "10.13.1.13"
  access_config {}
  }
 
 metadata {
    startup_script = "${file("./script.sh")}"  
    }

 }

resource "google_compute_instance" "ldap-client" {
  name         = "client"
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
  subnetwork = "${google_compute_subnetwork.public-subnet.self_link}"
  network_ip = "10.13.1.14"
  access_config {}
  }
 
 metadata {
    startup_script = "${file("./clientscript.sh")}"  
    }

 }


# resource "google_compute_firewall" "allow-ssh" {
#   name          = "allowssh"
#   network       = "${google_compute_network.vpc_network.self_link}"

#   allow {
#     protocol    = "tcp"
#     ports       = ["22"]
#   }

#   target_tags   = ["ssh"]
#}