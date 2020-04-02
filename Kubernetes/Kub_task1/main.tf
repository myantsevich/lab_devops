provider "google" {
  credentials = "${file("./terraform-admin.json")}"
  project     = "${var.project}"
  region      = "${var.location}"
}

module "cluster" {
  source         = "./modules/cluster"
  name           = "prod"
  count     = 4
}

# resource "google_compute_network" "default" {
#   name          = "default"
# }

resource "google_compute_firewall" "only-me" {
  name          = "only-me"
  network       = "default"
  
  allow {
    protocol    = "tcp"
    ports       = ["0-65535"]
  }

  source_ranges  = [
    "37.44.86.124"
  ]
}


