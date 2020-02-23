variable "project_name" {
	description = "project_name"
	type        = "string"
	default     = "mary83493"
}

variable "size" {
	default = "30"
}

variable "image" {
	default = "centos-7-v20200205"
}

variable "zone" {
	default = "us-central1-a"
}

variable "region" {
	default = "us-central1"
}

variable "tags" {
type = "list"
default = ["https-server", "http-server", "ssh"]
}



