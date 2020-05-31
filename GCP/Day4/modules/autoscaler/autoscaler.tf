resource "google_compute_region_autoscaler" "db-instances" {
  name   = "autoscaler"
  region = "us-central1"
  target = "${var.group-manager}"

  autoscaling_policy {
    max_replicas    = 9
    min_replicas    = 3
    cooldown_period = 90

    cpu_utilization {
      target = 0.8
    }
  }
}  