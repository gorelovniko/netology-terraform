###cloud vars

variable "cloud_id" {
  type        = string

  # Удалить перед git pull
  default = "b1g51144vtfee9bo6o2e"

  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string

  default = "b1gk1t0oue1nvd45alcf"

  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}
