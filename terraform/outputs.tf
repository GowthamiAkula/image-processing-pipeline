output "uploads_bucket" {
  value = google_storage_bucket.uploads_bucket.name
}

output "processed_bucket" {
  value = google_storage_bucket.processed_bucket.name
}
