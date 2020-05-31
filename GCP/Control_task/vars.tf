variable "project_name" {
  description = "project_name"
  type        = "string"
  default     = "mary83493"
}

variable "instance_count" {
  default = "2"
}

variable "size" {
default = "30"
}

variable "zones" {
default = "us-central1-a"
}

variable "tags" {
type = "list"
default = ["https-server", "http-server"]
}

output "link" {
  value = "${google_compute_instance.nginx-classwork-terraform.*.network_interface.0.access_config.0.nat_ip}"
}
