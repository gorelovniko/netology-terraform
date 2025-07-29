resource "local_file" "inventory" {
  content = templatefile("${path.module}/templates/hosts.tftpl", {
    webservers = local.inventory_data.webservers
    databases  = local.inventory_data.databases
    storage    = local.inventory_data.storage
  })
  filename = "${path.module}/inventory.ini"
}