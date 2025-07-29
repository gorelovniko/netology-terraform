# 1. Создаем 3 одинаковых диска по 1 Гб
resource "yandex_compute_disk" "storage_disks" {
  count = 3
  
  name     = "storage-disk-${count.index + 1}"
  type     = "network-hdd"
  zone     = var.default_zone
  size     = 1  # 1 ГБ
  block_size = 4096
}

# 2. Создаем одиночную ВМ "storage" (без count/for_each)
resource "yandex_compute_instance" "storage" {
  name        = "storage"
  hostname    = "storage"
  platform_id = var.default_platform_id
  zone        = var.default_zone

  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id # Ubuntu 20.04
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  # 3. Динамическое подключение созданных дисков
  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.storage_disks
    content {
      disk_id = secondary_disk.value.id
    }
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh_key}"
  }
}