provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_firewall" "ubuntu_fw" {
  name = "ubuntu_fw"
  droplet_ids = [digitalocean_droplet.ubuntu.id]

  inbound_rule {
    protocol     = "tcp"
    port_range   = "80"
    source_ips   = ["0.0.0.0/0"]
  }

}

resource "digitalocean_droplet" "ubuntu" {
  image  = "ubuntu-20-04-x64"
  name   = "ubuntu"
  region = "nyc3"
  size   = "s-1vcpu-1gb"

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y unzip
    apt install -y docker.io docker-compose
    usermod -aG docker $USER
    usermod -aG docker ubuntu
    # Дополнительная настройка, если необходимо
    mkdir new_project 
    cd new_project 
    touch docker-compose.yml
    reboot
  EOF

  ssh_keys = ["${digitalocean_ssh_key.ssh_key.id}"]
}

output "public_ips" {
  value = digitalocean_droplet.ubuntu.*.ipv4_address
}

output "ssh_commands" {
  value = [for ip in digitalocean_droplet.ubuntu.*.ipv4_address : "ssh -i 'terraform-key.pem' ubuntu@${ip}"]
}
