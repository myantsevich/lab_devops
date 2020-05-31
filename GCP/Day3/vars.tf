variable "project_name" {
	description = "project_name"
	type        = "string"
	default     = "mary83493"
}

variable "name" {
	default = "yantsevich"
}

variable "zone" {
	default = "us-central1-a"
}

variable "tags" {
type = "list"
default = ["https-server", "http-server"]
}



