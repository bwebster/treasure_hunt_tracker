terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

# Container Registry
data "digitalocean_container_registry" "docr" {
  name = "burkewebster"
}

# Block volume
resource "digitalocean_volume" "postgres_data" {
  name   = "postgres-data-volume"
  region = var.region
  size   = 2  # GB
}

resource "digitalocean_droplet" "web" {
  name   = "treasure-hunt-tracker"
  region = var.region
  size   = "s-1vcpu-1gb"
  image  = "docker-20-04"
  volume_ids = [digitalocean_volume.postgres_data.id]
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]

  # lifecycle {
  #   prevent_destroy = true  # Stops Terraform from destroying the droplet
  # }
}

resource "null_resource" "configure_server" {
  depends_on = [digitalocean_droplet.web]

  provisioner "file" {
    source      = "docker-compose.yml"
    destination = "/root/docker-compose.yml"

    connection {
      type        = "ssh"
      user        = "root"
      private_key = file(var.ssh_private_key_path)
      host        = digitalocean_droplet.web.ipv4_address
    }
  }

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "root"
      private_key = file(var.ssh_private_key_path)
      host = digitalocean_droplet.web.ipv4_address
    }

    inline = [
      # Wait until apt lock is released
      # "while sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1; do echo 'Waiting for apt lock...'; sleep 5; done",
      # "while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do echo 'Waiting for dpkg lock...'; sleep 5; done",
      # "while sudo fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do echo 'Waiting for apt lists lock...'; sleep 5; done",

      # "apt update -y",

      # Install doctl (DigitalOcean CLI)
      "sudo snap install doctl",
      "mkdir -p /root/.config/doctl",
      "chmod 700 /root/.config/doctl",

      # Get volume device path dynamically
      "VOLUME_DEVICE=${local.volume_device_path}",

      # Wait for the volume to be available
      "while [ ! -e $VOLUME_DEVICE ]; do echo 'Waiting for volume to attach...'; sleep 5; done",

      # If the volume is not formatted, format it
      "if ! blkid $VOLUME_DEVICE; then mkfs.ext4 -F $VOLUME_DEVICE; fi",

      # Create a mount point if it doesn't exist
      "mkdir -p /mnt/postgres_data",

      # Check if the volume is already mounted before mounting it
      "mountpoint -q /mnt/postgres_data || mount $VOLUME_DEVICE /mnt/postgres_data",

      # Ensure volume is mounted persistently across reboots
      "grep -qs $VOLUME_DEVICE /etc/fstab || echo '$VOLUME_DEVICE /mnt/postgres_data ext4 defaults,nofail 0 2' >> /etc/fstab",

      # Create a subdirectory for PostgreSQL
      "mkdir -p /mnt/postgres_data/pgdata",

      # Set proper ownership for PostgreSQL (UID 999 is default for postgres user in Docker)
      "chown -R 999:999 /mnt/postgres_data/pgdata",
      "chmod 700 /mnt/postgres_data/pgdata",

      # Restart Docker
      "systemctl restart docker",

      "ufw allow 80/tcp",
      "ufw reload",

      # Pull latest image
      "doctl auth init --access-token ${var.do_token}",
      "sudo snap connect doctl:dot-docker",
      "doctl registry login",
      "docker pull ${data.digitalocean_container_registry.docr.endpoint}/treasure_hunt_tracker:latest",

      "mkdir -p /opt/app",
      "cd /opt/app",
      "cp /root/docker-compose.yml .",

      "docker compose down web",
      "docker compose up -d"
    ]
  }

  triggers = {
    always_run = timestamp()
  }
}

resource "null_resource" "run_migrations" {
  depends_on = [null_resource.configure_server]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_private_key_path)
    host        = digitalocean_droplet.web.ipv4_address
  }

  provisioner "remote-exec" {
    inline = [
      # Wait for PostgreSQL to be ready
      "until docker exec $(docker ps -q --filter 'name=db') pg_isready -U postgres -d rails_production; do echo 'Waiting for database...'; sleep 5; done",

      # Run migrations inside the web container
      "docker exec $(docker ps -q --filter 'name=web') ./bin/rails db:migrate"
    ]
  }

  triggers = {
    always_run = timestamp()  # Ensures Terraform runs this only when needed
  }
}


resource "digitalocean_ssh_key" "default" {
  name = "my-ssh-key"
  public_key = file(var.ssh_public_key_path)
}

variable "do_token" {
  type = string
}
variable "ssh_private_key_path" {
  type = string
}
variable "ssh_public_key_path" {
  type = string
}

variable "region" {
  type = string
  default = "nyc3"
}

locals {
  volume_device_path = "/dev/disk/by-id/scsi-0DO_Volume_${digitalocean_volume.postgres_data.name}"
}

output "server_ip" {
  value = digitalocean_droplet.web.ipv4_address
}
