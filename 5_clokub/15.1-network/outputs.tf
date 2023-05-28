
output "vm1_external_address" {
value = yandex_compute_instance.VM1.network_interface.0.nat_ip_address
}
output "vm2_internal_address" {
value = yandex_compute_instance.VM2.network_interface.0.ip_address
}
