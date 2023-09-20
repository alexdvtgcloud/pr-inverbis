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

module "argocd" {
  source                        = "./modules/argocd/"
  cluster_name                  = module.gke.cluster_name #generate GKE dependency
  project_id                    = var.project_id
  env                           = var.env
  region                        = var.region
  argocd_ip_name                = module.networking.argocd_ip_name
  argocd_ip                     = module.networking.argocd_ip_address
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

module "cloud_build" {
  source                        = "./modules/cloud-build/"
  db_host                       = module.databases.ip_address_mysql
  redis_host                    = module.databases.ip_address_redis
  project_id                    = var.project_id
  repo_name                     = module.artifact_registry.repository_id
  cluster_name                  = module.gke.cluster_name
  region                        = var.region
  origin_branch                 = var.origin_branch
  repo_password                 = var.repo_password
  ip_socks_shop                 = module.networking.address_socks_shop
  cloud_source_repo             = var.cloud_source_repo
}

