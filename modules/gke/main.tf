# GKE cluster
resource "google_container_cluster" "primary" {
  name = "${var.env}-${var.name}"
  location = "${var.region}-b"  ##zonal cluster (also declared in google_container_node_pool.secondary_nodes and null_resource.kubectl [ArgoCD module] and cloudbuild.yaml)
  #location = "europe-west1"     regional cluster (3 AZ by default)
  project = var.project_id

  initial_node_count = 2

  network = var.id_network
  subnetwork = var.id_subnetwork
  networking_mode          = "VPC_NATIVE"

  private_cluster_config {
    enable_private_endpoint = "false"
    enable_private_nodes    = "true"
    master_global_access_config {
      enabled = "false"
    }
    master_ipv4_cidr_block = var.master_ipv4_cidr_block
  }
  node_config {
    spot = var.spot_vm
    disk_size_gb = 30
    disk_type    = "pd-standard"
    image_type   = "COS_CONTAINERD"
    machine_type = "e2-medium"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring", "https://www.googleapis.com/auth/cloud-platform", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/trace.append"
    ]
    service_account = "default"

    shielded_instance_config {
      enable_integrity_monitoring = true
    }
    labels = {
      node_pool = "default"
    }
    tags = ["gke-default-node", "${var.env}"]

  }
   release_channel {
    channel = "REGULAR"
  }

  logging_config {               
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS", "APISERVER", "CONTROLLER_MANAGER", "SCHEDULER"]  
  }
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS", "APISERVER"]
  }
  ip_allocation_policy {
    cluster_ipv4_cidr_block       = var.gke_cluster_ipv4_cidr_block
    services_ipv4_cidr_block      = var.gke_services_ipv4_cidr_block
    #cluster_secondary_range_name  = var.gke_cluster_secondary_range_name
    #services_secondary_range_name = var.gke_services_secondary_range_name
  }
}

# Separately Managed Node Pool
resource "google_container_node_pool" "secondary_nodes" {
  project = var.project_id
  name = "${google_container_cluster.primary.name}-managed-nodes"
  location = "${var.region}-b"
  cluster = google_container_cluster.primary.name
  #node_locations = var.locations    #multiple zones
  node_count = 0

  autoscaling {
    location_policy      = "ANY"  #BALANCED
    total_max_node_count = var.nodes_max
    total_min_node_count = var.nodes_min
  }

  node_config {
    spot = var.spot_vm
    disk_size_gb = 50
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring", "https://www.googleapis.com/auth/cloud-platform", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/trace.append"
    ]
    shielded_instance_config {
      enable_integrity_monitoring = true
    } 
    labels = {
      node_pool = "managed"
    }
    # preemptible = true
    machine_type = var.machine_type
    tags = ["gke-managed-node", "${var.env}"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

