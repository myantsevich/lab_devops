
resource "google_compute_forwarding_rule" "db-rule" {
  name                  = "db-lb"
  region                = "${var.region}"
  load_balancing_scheme = "INTERNAL"
  ports                 = ["80"]
  network               = "${var.vpc}"
  subnetwork            = "${var.priv-sub}"
  backend_service       = "${google_compute_region_backend_service.db-backend.self_link}"
}

resource "google_compute_region_backend_service" "db-backend" {
  name                  = "db-backend"
  region                = "${var.region}"
  health_checks         = ["${google_compute_health_check.hc.self_link}"]
  
  backend {
    group = "${var.group-name}"
  }
}

resource "google_compute_health_check" "hc" {
  name                  = "check-backend"
  check_interval_sec    = 10
  timeout_sec           = 10

  tcp_health_check {
    port = "80"
  }
}
