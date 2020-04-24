variable "access_key"{}
variable "secret_key" {}
variable "region" {
  default = "us-east-1" 
}
variable "image" {
  default = "ami-07ebfd5b3428b6f4d"
}
variable "type" {
  default = "t2.micro"
}
variable "tags" {
  type       = map
  default    = {
    "name"   = "vm1"
    "author" = "yantsevich"
  }
}


