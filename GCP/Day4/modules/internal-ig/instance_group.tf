
resource "google_compute_region_instance_group_manager" "group-manager2" {
  name               = "group-manager2"
  target_size        = "3"
  base_instance_name = "db"
  region             = "${var.region}"
  instance_template  = "${google_compute_instance_template.template2.self_link}"
}

output "group-name" {
  value = "https://www.googleapis.com/compute/v1/projects/mary83493/regions/us-central1/instanceGroups/group-manager2"
}