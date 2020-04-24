provider "aws" {
  region      = var.region
  access_key  = var.access_key
  secret_key  = var.secret_key
}

resource "aws_key_pair" "host_key" {
  key_name   = "terraformkey"
  public_key = file("id_rsa.pub")
}

resource "aws_s3_bucket" "example" {
  bucket = "s3-yantsevich"
  acl    = "private"
}

resource "aws_instance" "vm" {
  key_name        = aws_key_pair.host_key.key_name
  ami             = var.image
  instance_type   = var.type 
  subnet_id       = "subnet-e006f4bf"
  security_groups = ["sg-00c67952b713dbf92"]
  associate_public_ip_address = true
  depends_on      = [aws_s3_bucket.example]
  tags            = var.tags
}

resource "aws_eip" "lb" {
  instance     = aws_instance.vm.id
  vpc          = true

  provisioner "local-exec" {
    command    = "echo ${aws_eip.lb.public_ip} > ip_address"
  }
}

resource "null_resource" "ip"{
 provisioner "remote-exec" { 
    inline = [
      "sudo apt update",
      "sudo apt -y install nginx",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
      "sudo bash -c 'echo \"My EIP is: ${aws_eip.lb.public_ip}\" >> /var/www/html/index.nginx-debian.html'"
    ]
    on_failure  = continue
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("id_rsa")
      host        = aws_eip.lb.public_ip
    }
  }
}

output "ip" {
  value = "${aws_eip.lb.public_ip}"
}
