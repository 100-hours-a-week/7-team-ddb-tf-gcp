# terraform {
#   required_version = "1.11.4"
#   required_providers {
#     google = {
#       source  = "hashicorp/google"
#       version = "6.31.1"
#     }
#   }
#   backend "gcs" {
#     bucket      = "dolpin-terraform-state-30m1t350"
#     prefix      = "shared"
#     credentials = "../../secrets/account.json"
#   }
# }

# provider "google" {
#   credentials = file(var.credentials_file)
#   project     = var.project_id
#   region      = var.region
# }

# module "network" {
#   source           = "../../modules/network"
#   public_route_tag = var.public_tag
#   subnets = {
#     (var.public_service_name) : { cidr : var.public_cidr }
#   }
#   env = var.env
# }

# module "jenkins" {
#   source = "./modules/jenkins"

#   env                   = "shared"
#   jenkins_instance_name = "jenkins-shared"
#   machine_type          = var.jenkins_instance_type
#   zone                  = var.jenkins_zone
#   network               = module.network.vpc_self_link
#   subnetwork            = module.network.subnet_self_links[var.public_service_name]
#   project_id            = var.project_id
#   ssh_users             = var.ssh_users
#   allowed_ssh_cidrs     = var.allowed_ssh_cidrs
#   jenkins_service_name  = var.jenkins_service_name
#   jenkins_port          = var.jenkins_port
#   health_check_path     = var.health_check_path
#   mon_tag               = module.monitoring.mon_tag
# }

# module "dns" {
#   source                       = "../../modules/dns"
#   cdn_backend_bucket_self_link = ""
#   env                          = var.env
#   dns_managed_zone             = var.dns_zone_name
#   fallback_service_key         = var.jenkins_service_name
#   domains                      = [var.jenkins_domain]
#   network                      = module.network.vpc_self_link
#   services = {
#     (var.jenkins_service_name) : {
#       domain         = var.jenkins_domain
#       instance_group = module.jenkins.jenkins_group
#       health_check   = module.jenkins.health_check
#       port_name      = var.jenkins_service_name
#     }
#     (var.monitoring_service_name) : {
#       domain         = var.monitoring_domain
#       instance_group = module.monitoring.monitoring_group
#       health_check   = module.monitoring.health_check
#       port_name      = var.monitoring_service_name
#     }
#   }
# }

# module "monitoring" {
#   source              = "./modules/monitoring"
#   machine_type        = var.monitoring_instance_type
#   instance_monitoring = var.instance_monitoring
#   zone                = var.zone
#   public_key          = module.jenkins.jenkins_public_key
#   env                 = var.env
#   network             = module.network.vpc_self_link
#   subnetwork          = module.network.subnet_self_links[var.public_service_name]
#   ssh_users           = var.ssh_users
#   project_id          = var.project_id
#   service_name        = var.monitoring_service_name
# }

# module "nat_gateway" {
#   source        = "../../modules/nat_gateway"
#   env           = var.env
#   vpc_self_link = module.network.vpc_self_link
# }
