provider "google" {
  credentials = "${file("terraform-admin.json")}"
  project     = "${var.project_name}"
  region      = "us-central1"
}

resource "google_compute_instance" "nginx-terraform" {
  name         = "${var.name}"
  project     = "${var.project_name}"
  machine_type = "custom-1-4608"
  zone         = "${var.zones}"
  tags = "${var.tags}"

  boot_disk {
    initialize_params {
      image = "centos-7-v20200205"
      size = "${var.size}"
  	  type = "pd-ssd"
  	}
  	
  }

  labels = {
    servertype = "nginxserver"
    osfamily = "redhat"
    wayofinstalation = "terraform"
  }

  network_interface {
    network = "default"
    access_config {}
  }
  deletion_protection = true
  metadata_startup_script = "sudo yum install nginx -y"

}

resource "google_compute_disk" "nginx-gcp-terraform" {
  name   = "nginx-gcp-terraform"
  zone   = "${var.zones}"
  size   = "${var.size}"
}

resource "google_compute_attached_disk" "default" {
  disk     = "${google_compute_disk.nginx-gcp-terraform.self_link}"
  instance = "${google_compute_instance.nginx-terraform.self_link}"
}