variable "project_id" {
  description = "GCP Project ID"
  default     = "image-pipeline-456"
}

variable "region" {
  description = "GCP Region"
  default     = "us-central1"
}

variable "uploads_bucket_name" {
  default = "image-pipeline-uploads-456"
}

variable "processed_bucket_name" {
  default = "image-pipeline-processed-456"
}