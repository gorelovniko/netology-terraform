###cloud vars
# variable "token" {
#   type        = string
#   description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
# }

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "default_platform_id" {
  type        = string
  description = "platform_id"
}


variable "default_cidr" {
  type        = list(string)
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  description = "VPC network&subnet name"
}

variable "image_id" {
  type        = string
  description = "default image id for VM"
}

variable "each_vm" {
  type = list(object({
    vm_name     = string
    cpu         = number
    ram         = number
    disk_volume = number
  }))
  default = [
    {
      vm_name     = "main"
      cpu         = 4
      ram         = 4
      disk_volume = 10
    },
    {
      vm_name     = "replica"
      cpu         = 2
      ram         = 2
      disk_volume = 5
    }
  ]
}

locals {
  ssh_key = file("~/.ssh/id_ed25519.pub")
  
  inventory_data = {
    webservers = [
      for vm in yandex_compute_instance.web : {
        name = vm.name
        ip   = vm.network_interface[0].nat_ip_address
        fqdn = vm.fqdn
      }
    ],
    databases = [
      for name, vm in yandex_compute_instance.db : {
        name = vm.name
        ip   = vm.network_interface[0].nat_ip_address
        fqdn = vm.fqdn
      }
    ],
    storage = [{
      name = yandex_compute_instance.storage.name
      ip   = yandex_compute_instance.storage.network_interface[0].nat_ip_address
      fqdn = yandex_compute_instance.storage.fqdn
    }]
  }
}