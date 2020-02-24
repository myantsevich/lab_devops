provider "google" {
  credentials = "${file("/home/student/terraform-admin.json")}"
  project     = "${var.project_name}"
  region      = "${var.region}"
}
