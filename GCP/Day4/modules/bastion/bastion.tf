resource "google_compute_instance" "bastion" {
  name         = "bastion"
  machine_type = "n1-standard-1"
  zone         = "us-central1-c"
  tags         = ["ssh"]
 

  boot_disk {
    initialize_params {
      image   = "ubuntu-1604-xenial-v20200129"
      size    = "30"
      type    = "pd-ssd"
    }
    
  }

 network_interface {
    network    = "${var.vpc}"
    subnetwork = "${var.pub-sub}"
    access_config { }
  }

}

