provider "google" {
  project = var.project_id
  region  = var.region
  credentials = "terraform-cluster-admin.json"
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  credentials = "terraform-cluster-admin.json"
}
