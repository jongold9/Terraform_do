variable "alert_email" {
  description = "Email address for alert notifications"
}

resource "digitalocean_monitor_alert" "cpu_alert" {
  alerts {
    email = [var.alert_email]
  }
  window      = "5m"
  type        = "v1/insights/droplet/cpu"
  compare     = "GreaterThan"
  value       = 90
  enabled     = true
  entities    = [digitalocean_droplet.ubuntu.id]
  description = "Alert about CPU usage"
}

resource "digitalocean_monitor_alert" "memory_alert" {
  alerts {
    email = [var.alert_email]
  }
  window      = "5m"
  type        = "v1/insights/droplet/memory_utilization_percent"
  compare     = "GreaterThan"
  value       = 80
  enabled     = true
  entities    = [digitalocean_droplet.ubuntu.id]
  description = "Alert about memory usage"
}

resource "digitalocean_monitor_alert" "disk_io_alert" {
  alerts {
    email = [var.alert_email]
  }
  window      = "5m"
  type        = "v1/insights/droplet/disk_utilization_percent" 
  compare     = "GreaterThan"
  value       = 90
  enabled     = true
  entities    = [digitalocean_droplet.ubuntu.id]
  description = "Alert about disk I/O usage"
}

