resource "google_compute_instance_template" "template" {
  name            = "template"
  machine_type    = "n1-standard-1"
  tags            = ["http-server"]
  can_ip_forward  = true

  disk {
    source_image  = "ubuntu-1604-xenial-v20200129"
    auto_delete   = true
    boot          = true
  }

  network_interface {
    network       = "${var.vpc}"
    subnetwork    = "${var.pub-sub}"
    access_config { }
  }

  metadata_startup_script = "sudo apt-get install nginx -y"
}
