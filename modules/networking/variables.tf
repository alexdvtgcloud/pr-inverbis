variable "network" {
  description = "Network name"
  type = string
}

variable "project_id" {
  description = "The ID of the project where this VPC will be created"
  type        = string
}

variable "subnet" {
  description = "Subnet name"
  type = string
}

variable "region" {
  description = "The GCP region"
  type = string
}

variable "subnetwork_ipv4_cidr_block" {
  description = "CIDR of subnet"
  type = string
}

variable "env" {
  description = "Environment"
  type = string
}

variable "routing_mode" {
  type        = string
  default     = "REGIONAL"
  description = "The network routing mode (default 'GLOBAL')"
}
