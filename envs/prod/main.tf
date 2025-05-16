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
    prefix     = "prod"
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
    (var.be_service_name) : { cidr : var.be_cidr }
    (var.ai_service_name) : {cidr: var.ai_cidr}
    (var.fe_service_name) : {cidr: var.fe_cidr}
  }
  env = var.env
}

module "dns" {
  source                       = "../../modules/dns"
  cdn_backend_bucket_self_link = module.cloud_storage.cdn_backend_bucket_self_link
  env                          = var.env
  dns_managed_zone             = var.dns_zone_name
  fallback_service_key         = var.be_service_name
  domains                      = [var.be_domain, var.bucket_domain, var.ai_domain, var.fe_domain]
  network                      = module.network.vpc_self_link
  services = { 
    (var.be_service_name) : {
    domain         = var.be_domain
    instance_group = module.be.instance_group
    health_check   = module.be.health_check
    port_name      = var.be_service_name
    }
    (var.bucket_service_name) : {
      domain         = var.bucket_domain
      instance_group = ""
      health_check   = ""
      port_name      = ""
    }
    (var.ai_service_name) : {
      domain         = var.ai_domain
      instance_group = module.ai.instance_group
      health_check   = module.ai.health_check
      port_name      = var.ai_service_name
    }
    (var.fe_service_name) : {
      domain         = var.fe_domain
      instance_group = module.fe.instance_group
      health_check   = module.fe.health_check
      port_name      = var.fe_service_name
    }
  }
}

module "nat_bastion" {
  source            = "../../modules/nat_bastion"
  machine_type      = var.nat_bastion_instance_type
  network           = module.network.vpc_self_link
  subnetwork        = module.network.subnet_self_links[var.public_service_name]
  private_route_tag = var.private_tag
  public_route_tag  = var.public_tag
  allowed_ssh_cidrs = var.nat_bastion_allowed_ssh_cidrs
  ssh_users         = var.nat_bastion_ssh_users
  env               = var.env
  zone              = var.nat_bastion_zone
}

module "be" {
  source               = "../../modules/be"
  be_health_check_path = var.be_health_check_path
  subnetwork           = module.network.subnet_self_links[var.be_service_name]
  ig_port_name         = var.be_service_name
  zone                 = var.be_zone
  ssh_users            = var.be_ssh_users
  be_port              = var.be_port
  bastion_tag          = module.nat_bastion.nat_bastion_tag
  machine_type         = var.be_instance_type
  env                  = var.env
  private_route_tag    = var.private_tag
  network              = module.network.vpc_self_link
}

module "cloudsql" {
  source              = "../../modules/cloud_sql"
  env                 = var.env
  component           = "primary"
  tier                = "db-f1-micro"
  vpc_network_id      = module.network.vpc_self_link
  resource_type       = "db"
  deletion_protection = false
  db_name             = var.db_name
  db_user             = var.db_user
  db_password         = var.db_password
  backup_bucket_name = var.backup_bucket_name
  nat_ip_address      = module.nat_bastion.nat_ip
}

module "cloud_storage" {
  source = "../../modules/cloud_storage"

  env                            = var.env
  bucket_name                    = var.bucket_name
  location                       = "ASIA"
  force_destroy                  = true
  cors_origins                   = [var.cors_origin]
  backend_service_account_email  = var.backend_service_account_email
}

module "ai" {
  source = "../../modules/ai"
  env               = var.env
  network           = module.network.vpc_self_link
  subnetwork        = module.network.subnet_self_links[var.ai_service_name]
  zone              = var.ai_zone
  machine_type      = var.ai_instance_type
  ssh_users         = var.ai_ssh_users
  private_route_tag = var.private_tag
  bastion_tag       = module.nat_bastion.nat_bastion_tag
  ai_port           = var.ai_port
  ai_port_name      = var.ai_service_name
  health_check_path = var.ai_health_check_path
}

module "fe" {
  source            = "../../modules/fe"
  env               = var.env
  network           = module.network.vpc_self_link
  subnetwork        = module.network.subnet_self_links[var.fe_service_name]
  zone              = var.fe_zone
  machine_type      = var.fe_instance_type
  ssh_users         = var.fe_ssh_users
  private_route_tag = var.private_tag
  bastion_tag       = module.nat_bastion.nat_bastion_tag
  fe_port           = var.fe_port
  ig_port_name      = var.fe_service_name
  health_check_path = var.fe_health_check_path
}
