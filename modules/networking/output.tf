
output "id_network"{
    description = "ID generated network"
    value = google_compute_network.vpc_network.id
}
output "id_subnet"{
    description = "ID generated subnet"
    value = google_compute_subnetwork.subnet.id
}

output "address_inverbis" {
  description = "The address of test app"
  value = google_compute_global_address.inverbis.address
}

output "private_ip_name" {
  description = "Name of private IP for Cloud SQL"
  value = google_compute_global_address.private_ip_address.name
}
