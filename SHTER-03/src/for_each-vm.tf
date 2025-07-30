resource "yandex_compute_instance" "db" {
  for_each = { for vm in var.each_vm : vm.vm_name => vm }

  name        = each.value.vm_name
  hostname    = each.value.vm_name
  platform_id = var.default_platform_id
  zone        = var.default_zone
  
  allow_stopping_for_update = true

  resources {
    cores  = each.value.cpu
    memory = each.value.ram
  }

  boot_disk {
    initialize_params {
      image_id = "fd8u8ttgp0t4d19ov0k5" # Ubuntu-20.04-lts
      size     = each.value.disk_volume
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
    ssh-keys = "ubuntu:${local.ssh_key}"
  }

}