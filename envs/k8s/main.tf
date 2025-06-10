terraform {
  required_version = "1.11.4"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.31.1"
    }
  }
  backend "gcs" {
    bucket      = "dolpin-terraform-state-31m1t350"
    prefix      = "k8s"
    credentials = "../../secrets/accountk8s.json"
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project_id
  region      = var.region
}

module "network" {
  source           = "../../modules/network"
  env              = var.env

  subnets = {
    gke = {
      cidr = var.gke_cidr
      secondary_ranges = {
        pods     = var.gke_pods_range
        services = var.gke_services_range
      }
    }
  }
}

module "cloudsql" {
  source              = "../../modules/cloud_sql"
  env                 = var.env
  component           = var.component
  tier                = var.tier
  resource_type       = var.resource_type
  deletion_protection = var.deletion_protection
  db_name             = var.db_name
  db_user             = var.db_user
  nat_ip_address      = module.nat_gateway.nat_ip
}

module "cloud_storage" {
  source = "../../modules/cloud_storage"

  env                           = var.env
  bucket_name                   = var.bucket_name
  location                      = var.location
  force_destroy                 = true
  cors_origins                  = [var.cors_origin]
  backend_service_account_email = var.be_service_account_email
}

module "nat_gateway" {
  source        = "../../modules/nat_gateway"  
  env           = var.env
  vpc_self_link = module.network.vpc_self_link
}

module "gar" {
  source           = "../../modules/gar"
  location         = var.location
  env              = var.env
  format           = var.gar_format
  immutable_tags   = var.immutable_tags
  cleanup_policies = var.cleanup_policies
}