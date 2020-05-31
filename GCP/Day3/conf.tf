provider "google" {
  credentials = "${file("/home/student/Terraform/terraform-admin.json")}"
  project     = "${var.project_name}"
  region      = "us-central1"
}

resource "google_compute_network" "vpc_network" {
  name = "${var.name}-vpc"
  project     = "${var.project_name}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "private-subnet" {
  name          = "${var.name}-private-subnet"
  ip_cidr_range = "10.13.2.0/24"
  region        = "us-central1"
 // zone          = "${var.zones}"
  network       = "${var.name}-vpc"
  depends_on    = ["google_compute_network.vpc_network"]
  private_ip_google_access = "true"
}

resource "google_compute_subnetwork" "public-subnet" {
  name          = "${var.name}-public-subnet"
  ip_cidr_range = "10.13.1.0/24"
  region        = "us-central1"
  // zone          = "${var.zones}"
  network       = "${var.name}-vpc"
  depends_on    = ["google_compute_network.vpc_network"]
}

resource "google_compute_firewall" "allow-ssh-http" {
  name    = "allow-ssh-http"
  network = "${var.name}-vpc"

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }
}

resource "google_compute_firewall" "allow-internal" {
  name    = "allow-internal"
  network = "${var.name}-vpc"

  allow {
    protocol = "tcp"
  }
  direction = "EGRESS"
}

