resource "google_compute_instance_template" "template2" {
  name            = "template2"
  machine_type    = "n1-standard-1"
  tags            = ["http-server", "ssh"]
  can_ip_forward  = true

  disk {
    source_image  = "ubuntu-1604-xenial-v20200129"
    auto_delete   = true
    boot          = true
  }

  network_interface {
    network       = "${var.vpc}"
    subnetwork    = "${var.priv-sub}"
    access_config { }
  }

  metadata_startup_script = "sudo apt-get install nginx -y \nsudo bash -c 'echo \"Hi! I'm $(hostname -I)\" > /var/www/html/index.nginx-debian.html '\nsudo systemctl restart nginx"
}
