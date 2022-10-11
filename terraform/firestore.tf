resource "google_firestore_document" "clusters" {
  project     = var.project_id
  collection  = "clusters"
  document_id = ""
  fields      = ""
}