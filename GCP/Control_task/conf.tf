provider "google" {
  credentials = "${file("terraform-admin.json")}"
  project     = "${var.project_name}"
  region      = "us-central1"
}

resource "google_compute_instance" "nginx-classwork-terraform" {
  count        = "${var.instance_count}"
  name         = "nginx-classwork-terraform-${count.index + 1}"
  project      = "${var.project_name}"
  machine_type = "custom-1-1792"
  zone         = "${var.zones}"
  tags = "${var.tags}"

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20200129"
      size = "${var.size}"
  	  type = "pd-ssd"
  	}
  }

  labels = {
    servertype = "nginxserver"
    osfamily = "debian"
    wayofinstalation = "terraform"
  }

  network_interface {
    network = "default"
    access_config {}
  }

  timeouts {
   delete = "40m"
  }

  deletion_protection = true
  description = "instance for control task-${count.index + 1}"
  metadata_startup_script = "sudo apt-get install nginx -y"

}
