resource "yandex_compute_instance" "web" {
  count    = var.web_instance_count
  name     = "${var.web_instance_name_prefix}-${count.index + 1}"
  hostname = "${var.web_instance_name_prefix}-${count.index + 1}"
  
  resources {
    cores  = var.web_instance_cpu
    memory = var.web_instance_memory
  }

  boot_disk {
    initialize_params {
      image_id = "fd8u8ttgp0t4d19ov0k5" # Ubuntu-20.04-lts
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys = "${var.web_instance_username}:${local.ssh_key}"
  }

  depends_on = [yandex_compute_instance.db]

}