variable "do_token" {
  description = "DigitalOcean API токен"
}

variable "ssh_key_path" {
  description = "Путь к приватному SSH ключу"
}

variable "region" {
  description = "Регион, в котором будет созданы ресурсы"
  default     = "nyc3"
}

variable "instance_type" {
  description = "Тип инстанса (размер)"
  default     = "s-1vcpu-1gb"
}

variable "image" {
  description = "Образ операционной системы"
  default     = "ubuntu-20-04-x64"
}

variable "ssh_key_name" {
  description = "Имя SSH ключа в DigitalOcean"
  default     = "terraform-key"
}
