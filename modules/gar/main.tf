resource "google_artifact_registry_repository" "this" {
  location      = var.location
  repository_id = "dolpin-docker-image-${var.env}"
  format        = var.format
  mode          = "STANDARD_REPOSITORY"

  dynamic "docker_config" {
    for_each = var.format == "DOCKER" ? [1] : []
    content {
      immutable_tags = var.immutable_tags
    }
  }

  dynamic "cleanup_policies" {
    for_each = var.cleanup_policies
    content {
      id     = cleanup_policies.value.id
      action = cleanup_policies.value.action
      condition {
        tag_state    = lookup(cleanup_policies.value.condition, "tag_state", null)
        tag_prefixes = lookup(cleanup_policies.value.condition, "tag_prefixes", null)
        older_than   = lookup(cleanup_policies.value.condition, "older_than", null)
        newer_than   = lookup(cleanup_policies.value.condition, "newer_than", null)
      }
    }
  }

  labels = {
    Name        = "artifact-repo-${var.env}"  
    component   = "backend"                          
    env         = var.env                             
    type        = "artifact-registry"                 
    managed_by  = "terraform"                        
    service     = "backend"                           
  }
}