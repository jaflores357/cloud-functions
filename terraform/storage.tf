resource "google_storage_bucket" "function_bucket" {
  name     = "${var.project_id}-clusters-api-functions"
  location = var.region
}
