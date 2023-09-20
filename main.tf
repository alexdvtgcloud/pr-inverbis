module "networking" {
  source                        = "./modules/networking/"
  network                       = var.network
  project_id                    = var.project_id
  subnet                        = var.subnet
  region                        = var.region
  subnetwork_ipv4_cidr_block    = var.subnetwork_ipv4_cidr_block
  env                           = var.env
}

module "gke" {
  source                        = "./modules/gke/"
  project_id                    = var.project_id
  name                          = var.cluster_name
  env                           = var.env
  region                        = var.region
  id_network                    = module.networking.id_network
  id_subnetwork                 = module.networking.id_subnet
  master_ipv4_cidr_block        = var.master_ipv4_cidr_block
  gke_cluster_ipv4_cidr_block   = var.gke_cluster_ipv4_cidr_block
  gke_services_ipv4_cidr_block  = var.gke_services_ipv4_cidr_block
  spot_vm                       = var.spot_vm
  
  #Managed node pool
  machine_type                  = var.machine_type
  nodes_max                     = var.nodes_max
  nodes_min                     = var.nodes_min
}

module "databases" {
  source                        = "./modules/databases/"
  project_id                    = var.project_id
  id_network                    = module.networking.id_network
  region                        = var.region
  mysql_password                = var.mysql_password
  private_ip_name               = module.networking.private_ip_name
}

module "secret_manager" {
  source                        = "./modules/secret-manager/"
  env                           = var.env
  project_id                    = var.project_id
  region                        = var.region
  mysql_password                = var.mysql_password

  count                         = "${length(var.secrets_id)}"
  secret_id                     = "${var.secrets_id[count.index]}"
}

/* Add the secret data for db-password secret */
resource "google_secret_manager_secret_version" "db_password" {
  secret                        = module.secret_manager[0].secret_name
  secret_data                   = var.mysql_password
}

module "artifact_registry" {
  source                        = "./modules/artifact-registry/"
  project_id                    = var.project_id
  repository_name = var.repository_name
}


