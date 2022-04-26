resource "null_resource" "docker_swarm_init_manager" {
  depends_on = [yandex_compute_instance.vm_manager]

  connection {
    user        = var.ssh_credentials.user
    private_key = file(var.ssh_credentials.private_key)
    host        = yandex_compute_instance.vm_manager[0].network_interface.0.nat_ip_address
  }

  provisioner "file" {
    source      = "scripts"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/scripts/setup.sh",
      "sudo /tmp/scripts/setup.sh",
      "sudo docker swarm init --advertise-addr ${yandex_compute_instance.vm_manager[0].network_interface.0.nat_ip_address}",
      "chmod +x /tmp/scripts/drain.sh",
      "sudo /tmp/scripts/drain.sh" # Enable manager-only mode
    ]
  }

  provisioner "local-exec" {
    command = "/bin/sh scripts/fetch-tokens.sh"
    environment = {
      SSH_KEY  = var.ssh_credentials.private_key
      HOST     = yandex_compute_instance.vm_manager[0].network_interface.0.nat_ip_address
      SSH_USER = var.ssh_credentials.user
    }
  }
}

resource "null_resource" "docker_swarm_manager" {
  count = var.managers - 1
  depends_on = [yandex_compute_instance.vm_manager, null_resource.docker_swarm_init_manager]

  connection {
    user        = var.ssh_credentials.user
    private_key = file(var.ssh_credentials.private_key)
    host        = yandex_compute_instance.vm_manager[count.index + 1].network_interface.0.nat_ip_address
  }

  provisioner "remote-exec" {
    scripts = [
      "scripts/setup.sh",
      "scripts/manager.join.sh", # Join to the swarm as a manager node
      "scripts/drain.sh"         # Enable manager-only mode
    ]
  }
}

resource "null_resource" "docker_swarm_worker" {
  count = var.workers
  depends_on = [yandex_compute_instance.vm_worker, null_resource.docker_swarm_init_manager]

  connection {
    user        = var.ssh_credentials.user
    private_key = file(var.ssh_credentials.private_key)
    host        = yandex_compute_instance.vm_worker[count.index].network_interface.0.nat_ip_address
  }

  provisioner "remote-exec" {
    scripts = [
      "scripts/setup.sh",
      "scripts/worker.join.sh" # Join to the swarm as a worker node
    ]
  }
}

resource "null_resource" "stack_deploy" {
  depends_on = [null_resource.docker_swarm_worker, null_resource.docker_swarm_manager]

  connection {
    user        = var.ssh_credentials.user
    private_key = file(var.ssh_credentials.private_key)
    host        = yandex_compute_instance.vm_manager[0].network_interface.0.nat_ip_address
  }

  provisioner "file" {
    source      = "docker-compose.yml"
    destination = "/tmp/docker-compose.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo docker stack deploy --compose-file /tmp/docker-compose.yml sockshop-swarm",
    ]
  }
}

resource "null_resource" "cleanup" {
  depends_on = [null_resource.stack_deploy]

  provisioner "local-exec" {
    command = "rm scripts/*.join.sh"
  }
}
