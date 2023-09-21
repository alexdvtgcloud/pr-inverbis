variable "project_id" {
  description = "The ID of the project where this VPC will be created"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type = string
}

variable "env" {
  description = "Environment"
  type = string
}

variable "name" {
  description = "Name of cluster"
  type = string
}

variable "id_network"{
  description = "ID generated network"
}

variable "id_subnetwork"{
  description = "ID generated subnet"
}

variable "namespace" {
  description = "The GKE namespace where Argocd is deployed"
  type        = string
  default = "argocd"
}

variable "gke_cluster_ipv4_cidr_block" {
  description = "The IP address range of the Kubernetes pods in this cluster in CIDR notation."
}

variable "gke_services_ipv4_cidr_block" {
  description = "The IP address range of the services IPs in this cluster."
}

variable "master_ipv4_cidr_block" {
  description = "The IP address range of the control plane endpoint in this cluster."
}

variable "nodes_min" {
  description = "number of nodes"
  type = number
  default = 0
}

variable "nodes_max" {
  description = "number of nodes"
  type = number
  default = 4
}

variable "locations" {
  description = "The list of zones in which the node pool's nodes should be located"
  type = list
  default = [
    "europe-west1-b",
    "europe-west1-c",
    "europe-west1-d",
  ]
}

variable "machine_type" {
  description = "Type of machine"
  type = string
}

variable "spot_vm" {
  type = bool
}
