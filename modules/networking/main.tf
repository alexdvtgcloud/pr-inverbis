resource "google_compute_network" "vpc_network" {
  name                    = var.network
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = var.routing_mode
}

resource "google_compute_subnetwork" "subnet" {
  project = var.project_id
  network = google_compute_network.vpc_network.self_link
  name    = var.subnet
  region  = var.region
  ip_cidr_range = var.subnetwork_ipv4_cidr_block
}

resource "google_compute_router" "router" {
  name    = "${var.env}-router"
  project = var.project_id
  region  = var.region
  network = google_compute_network.vpc_network.id
}

resource "google_compute_address" "nat_address" {
  name          = "${var.env}-nat-ip"
  project       = var.project_id
  address_type  = "EXTERNAL"
  network_tier  = "PREMIUM"
  prefix_length = 0
  region        = var.region
}

resource "google_compute_router_nat" "cloud_nat" {
  name                   = "${var.env}-nat"
  project                = var.project_id
  router                 = google_compute_router.router.name
  region                 = google_compute_router.router.region
  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.nat_address.*.self_link

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }

  depends_on = [
    google_compute_router.router
  ]
}

resource "google_vpc_access_connector" "connector" {
  name          = "vpc-demo-connector"
  project       = var.project_id
  ip_cidr_range = "10.8.0.0/28"
  network       = google_compute_network.vpc_network.name
  region        = var.region
  depends_on    = [google_compute_network.vpc_network]
}

resource "google_compute_global_address" "inverbis" {
  name    = "inverbis-ip-ingress"
  project = var.project_id
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc_network.id
  project = var.project_id
}
