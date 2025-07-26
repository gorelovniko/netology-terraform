# YC zones

variable "default_zone_a" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "default_zone_b" {
  type        = string
  default     = "ru-central1-b"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

# YC subnets

variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "db_cidr" {
  type        = list(string)
  default     = ["10.0.2.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

# YC subnets name

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network & subnet name"
}

variable "vpc_db_name" {
  type        = string
  default     = "develop_db"
  description = "DB subnet name"
}

# YC name image and id platform

variable "vm_web_image_family" {
  type    = string
  default = "ubuntu-2004-lts"
}

variable "vm_web_platform_id" {
  type    = string
  default = "standard-v3"
}

variable "vm_db_image_family" {
  type    = string
  default = "ubuntu-2004-lts"
}

variable "vm_db_platform_id" {
  type    = string
  default = "standard-v3"
}

###ssh vars

# variable "vms_ssh_public_root_key" {
#   type        = string
#   default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJUbS7hoNixx/pbzRt3xf5xYMuq2x6RBXFHslOjQ6JAC alt@host-75"
#   description = "ssh-keygen -t ed25519"
# }

# Name VM

variable "vm_web_name" {
  type    = string
  default = "web"
}

variable "vm_db_name" {
  type    = string
  default = "db"
}

variable "full_name" {
  type    = string
  default = "netology-develop-platform"
}

# tfvars

variable "vms_resources" {
  type = map(object({
    cores         = number
    memory        = number
    core_fraction = number
  }))
  default = {
    web = {
      cores         = 2
      memory        = 1
      core_fraction = 20
    }
    db = {
      cores         = 2
      memory        = 2
      core_fraction = 20
    }
  }
}

variable "metadata" {
  type = object({
    serial-port-enable = number
    ssh-keys           = string
  })
  default = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJUbS7hoNixx/pbzRt3xf5xYMuq2x6RBXFHslOjQ6JAC alt@host-75"
  }
}