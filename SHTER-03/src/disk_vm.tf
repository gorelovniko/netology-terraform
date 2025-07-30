# 1. Создаем 3 одинаковых диска по 1 Гб
resource "yandex_compute_disk" "storage_disks" {
  count      = var.storage_disks_count
  
  name       = "${var.storage_disk_name_prefix}-${count.index + 1}"
  type       = var.storage_disk_type
  zone       = var.default_zone
  size       = var.storage_disk_size_gb
  block_size = var.storage_disk_block_size
}

# 2. Создаем одиночную ВМ "storage" (без count/for_each)
resource "yandex_compute_instance" "storage" {
  name        = var.storage_vm_name
  hostname    = var.storage_vm_name
  platform_id = var.default_platform_id
  zone        = var.default_zone

  allow_stopping_for_update = true

  resources {
    cores  = var.storage_vm_cpu_cores
    memory = var.storage_vm_memory_gb
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_image.id # Ubuntu-20.04-lts
      size     = var.storage_vm_boot_disk_size_gb
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
    ssh-keys = "${var.storage_instance_username}:${local.ssh_key}"
  }
}