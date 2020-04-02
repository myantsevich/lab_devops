
variable "name" {}

variable "count" {}

variable "project" {
  default = "mary1kubik"
}

variable "location" {
  default = "us-central1-a"
}

variable "initial_node_count" {
  default = 1
}

variable "machine_type" {
  default = "n1-standard-1"  
}