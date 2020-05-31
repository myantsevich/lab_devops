resource "google_compute_instance" "nginx-terraform" {
  name         = "${var.name}"
  project     = "${var.project_name}"
  machine_type = "custom-1-4608"
  zone         = "${var.zone}"
  depends_on    = ["google_compute_subnetwork.public-subnet"]
  tags = "${var.tags}"

  boot_disk {
    initialize_params {
      image = "centos-7-v20200205"
      size = "30"
      type = "pd-ssd"
    }
    
  }

 network_interface {
    network = "${var.name}-vpc"
    subnetwork = "${var.name}-public-subnet"
    access_config {
    }
  }
  
  metadata_startup_script = <<EOF
	sudo yum install nginx -y
	sudo systemctl start nginx
	sudo echo -e "<h1>¯\_(ツ)_/¯</h1> \n <h1>Hello from Marina</h1>" > /home/m_yantsevich/index.html 
	sudo cp /home/m_yantsevich/index.html  /usr/share/nginx/html/index.html
	sudo systemctl restart nginx
	EOF
  
}

output "link" {
value = "${google_compute_instance.nginx-terraform.*.network_interface.0.access_config.0.nat_ip}"
}