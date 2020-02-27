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
  network       = "${google_compute_network.vpc.self_link}"
  depends_on    = ["google_compute_subnetwork.public-subnet"]

  allow {
    protocol    = "tcp"
    ports       = ["0-65535"]
  }
}

resource "google_compute_instance" "vm" {
  count         = "${var.instance_count}"
  name          = "vm-${count.index + 1}"
  //name          = "vm1"
  project       = "${var.project_name}"
  machine_type  = "${var.type}"
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
    network_ip = "10.13.1.2${count.index + 1}"
    access_config {}
  }
 
   metadata_startup_script = "${file("./script-vm${count.index + 1}.sh")}" 

}

