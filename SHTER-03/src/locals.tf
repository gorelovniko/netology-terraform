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