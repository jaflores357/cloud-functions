data "archive_file" "zip" {
  type        = "zip"
  source_dir  = "../src/${var.function}"
  output_path = "dist/${var.function}.zip"
}

resource "google_storage_bucket_object" "object" {
  source       = data.archive_file.zip.output_path
  content_type = "application/zip"

  name   = "src-${data.archive_file.zip.output_md5}.zip"
  bucket = var.bucket_name

  depends_on = [
    data.archive_file.zip
  ]
}

resource "google_cloudfunctions2_function" "function" {
  name        = var.function
  location    = var.region
  description = "Function ${var.function}"

  build_config {
    runtime     = "python310"
    entry_point = "main"
    source {
      storage_source {
        bucket = var.bucket_name
        object = google_storage_bucket_object.object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
  depends_on = [
    google_storage_bucket_object.object
  ]
}
