variable "project_name" {
  description = "project_name"
  type        = "string"
  default     = "mary83493"
}

variable "name" {
default = "nginx-terraform"
}

variable "size" {
default = "30"
}

variable "zones" {
default = "us-central1-c"
}

variable "tags" {
type = "list"
default = ["https-server", "http-server"]
}

output "http" {
  value = "http://${google_compute_instance.nginx-terraform.network_interface.0.access_config.0.nat_ip}"
}