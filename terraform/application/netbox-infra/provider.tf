provider "google-beta" {
  project = var.project_id
  region  = var.region
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# data "google_client_config" "default" {
#   depends_on = [module.gke_autopilot]
# }

# # Defer reading the cluster data until the GKE cluster exists.
# data "google_container_cluster" "default" {
#   name = local.cluster_name
#   location = var.region
#   depends_on = [module.gke_autopilot]
# }

# provider "kubernetes" {
#   host  = "https://${data.google_container_cluster.default.endpoint}"
#   token = data.google_client_config.default.access_token
#   cluster_ca_certificate = base64decode(
#     data.google_container_cluster.default.master_auth[0].cluster_ca_certificate,
#   )
# }
