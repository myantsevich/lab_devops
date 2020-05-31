
resource "google_compute_region_instance_group_manager" "group-manager" {
  name               = "group-manager"
  target_size        = "1"
  base_instance_name = "nginx"
  region             = "us-central1"
  instance_template  = "${google_compute_instance_template.template.self_link}"
}

output "group-name" {
  value = "https://www.googleapis.com/compute/v1/projects/mary83493/regions/us-central1/instanceGroups/group-manager"
}

output "group-manager" {
  value = "${google_compute_region_instance_group_manager.group-manager.self_link}"
}