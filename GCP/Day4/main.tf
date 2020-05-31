provider "google" {
  credentials = "${file("/home/student/Terraform/terraform-admin.json")}"
  project     = "${var.project_name}"
  region      = "${var.region}"
}

module "network" {
  source      = "./modules/network"
}
module "bastion" {
  source      = "./modules/bastion"
  vpc         = "${module.network.vpc}"
  pub-sub     = "${module.network.pub-sub}" 
}
module "ig" {
  source      = "./modules/ig"
  vpc         = "${module.network.vpc}"
  pub-sub     = "${module.network.pub-sub}" 
}
module "internal-ig" {
  source      = "./modules/internal-ig"
  vpc         = "${module.network.vpc}"
  priv-sub    = "${module.network.priv-sub}" 
}

module "autoscaler" {
  source      = "./modules/autoscaler"
  group-manager  = "${module.ig.group-manager}"
}

module "gce-lb-http" {
  version      = "1.0.10"
  source       = "GoogleCloudPlatform/lb-http/google"
  name         = "group-http-lb"
  target_tags  = ["web"]
  backends     = {
    "0" = [
      { group  = "${module.ig.group-name}" }
    ],
  }
  backend_params = ["/,http,80,10"]
}

module "internal-lb" {
  source      = "./modules/internal-lb"
  vpc         = "${module.network.vpc}"
  priv-sub    = "${module.network.priv-sub}" 
  group-name  = "${module.internal-ig.group-name}"
}

resource "google_storage_bucket" "static-content-store" {
  name     = "static-content-store-bucket"
  location = "US"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}