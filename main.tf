terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token  # Используем токен DigitalOcean API
}

# Создаем SSH ключ в DigitalOcean
resource "digitalocean_ssh_key" "my_ssh_key" {
  name       = var.ssh_key_name  # Имя SSH ключа
  public_key = file(var.ssh_key_path)  # Публичный SSH ключ
}

# Создаем правила брандмауэра
resource "digitalocean_firewall" "ubuntu_fw" {
  name        = "ubuntufw"  # Имя брандмауэра
  droplet_ids = [digitalocean_droplet.ubuntu.id]  # Идентификаторы droplet'ов, к которым применяются правила

  # Входные правила для открытия портов 80, 443 и 22
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0"]  # Разрешенные источники для порта 80
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0"]  # Разрешенные источники для порта 443
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0"]  # Разрешенные источники для порта 22
  }

  # Исходящее правило для разрешения всех TCP и UDP трафика
  outbound_rule {
    protocol            = "tcp"
    destination_addresses = ["0.0.0.0/0"]  # Разрешенные назначения для всех портов
    port_range          = "1-65535"  # Установка диапазона портов для TCP
  }

  outbound_rule {
    protocol            = "udp"
    destination_addresses = ["0.0.0.0/0"]  # Разрешенные назначения для всех портов
    port_range          = "1-65535"  # Установка диапазона портов для UDP
  }
}

# Создаем droplet
resource "digitalocean_droplet" "ubuntu" {
  image  = var.image  # Образ операционной системы
  name   = "ubuntu"  # Имя droplet'а
  region = var.region  # Регион
  size   = var.instance_type  # Тип инстанса

  # Скрипт инициализации для droplet'а
  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.pvt_key)
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir new_project",
      "apt update -y",
      "apt install -y unzip",
      "apt install -y docker.io",
      "apt install -y docker-compose",
      "usermod -aG docker $USER",
      "usermod -aG docker root"
    ]
  }

  ssh_keys = [digitalocean_ssh_key.my_ssh_key.id]  # Используем созданный SSH ключ
}

# Выводим публичные IP адреса созданных droplet'ов
output "public_ips" {
  value = digitalocean_droplet.ubuntu.*.ipv4_address
}

# Выводим команды для SSH доступа к созданным droplet'ам
output "ssh_commands" {
  value = [for ip in digitalocean_droplet.ubuntu.*.ipv4_address : "ssh -i '~/.ssh/do' root@${ip}"]
}
