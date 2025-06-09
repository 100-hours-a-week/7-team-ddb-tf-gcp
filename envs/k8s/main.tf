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
