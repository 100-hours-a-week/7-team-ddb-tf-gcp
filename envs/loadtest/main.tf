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
    prefix      = "loadtest"
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
  public_route_tag = var.public_tag
  subnets = {
    (var.public_service_name) : { cidr : var.public_cidr }
  }
  env = var.env
}

module "k6" {
  source                = "./modules/k6"
  env                   = var.env
  zone                  = var.zone
  machine_type          = var.machine_type
  network               = module.network.vpc_self_link
  subnetwork            = module.network.subnet_self_links[var.public_service_name]
  instance_tag          = var.public_tag
  ssh_users             = var.ssh_users
}

module "influxDB" {
  source                = "./modules/influxDB"
  env                   = var.env
  zone                  = var.zone
  network               = module.network.vpc_self_link
  subnetwork            = module.network.subnet_self_links[var.public_service_name]
}