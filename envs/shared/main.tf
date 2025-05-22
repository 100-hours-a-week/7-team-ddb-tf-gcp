terraform {
  required_version = "1.11.4"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.31.1"
    }
  }
  backend "gcs" {
    bucket      = "dolpin-terraform-state-29m1t350"
    prefix     = "shared"
    credentials = "../../secrets/account.json"
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

module "jenkins" {
  source = "./modules/jenkins"

  env                   = "shared"
  jenkins_instance_name = "jenkins-shared"
  machine_type          = var.jenkins_instance_type
  zone                  = var.jenkins_zone
  network               = module.network.vpc_self_link
  subnetwork            = module.network.subnet_self_links[var.public_service_name]
  project_id            = var.project_id
  ssh_users             = var.ssh_users
  allowed_ssh_cidrs     = var.allowed_ssh_cidrs
}