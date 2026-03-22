provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}


# Uploads Bucket
resource "google_storage_bucket" "uploads_bucket" {
  name     = var.uploads_bucket_name
  location = var.region

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 7
    }
  }
}

# Processed Bucket
resource "google_storage_bucket" "processed_bucket" {
  name     = var.processed_bucket_name
  location = var.region
}
# Service Account for Cloud Functions
resource "google_service_account" "function_sa" {
  account_id   = "image-pipeline-sa"
  display_name = "Service Account for Image Pipeline"
}

# Grant Storage access
resource "google_project_iam_member" "storage_access" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}

# Grant Pub/Sub access
resource "google_project_iam_member" "pubsub_access" {
  project = var.project_id
  role    = "roles/pubsub.editor"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}

# Grant Logging access
resource "google_project_iam_member" "logging_access" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}

# Grant Secret Manager access
resource "google_project_iam_member" "secret_access" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}
# Pub/Sub Topic for processing requests
resource "google_pubsub_topic" "image_processing_requests" {
  name = "image-processing-requests"
}

# Pub/Sub Topic for results
resource "google_pubsub_topic" "image_processing_results" {
  name = "image-processing-results"
}
# Secret Manager - API Key
resource "google_secret_manager_secret" "api_key" {
  secret_id = "image-pipeline-api-key"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "api_key_version" {
  secret      = google_secret_manager_secret.api_key.id
  secret_data = "my-secure-api-key-123"
}
# Archive upload function code
data "archive_file" "upload_function_zip" {
  type        = "zip"
  source_dir  = "../functions/upload-image"
  output_path = "../functions/upload-image.zip"
}

# Cloud Function (2nd Gen)
resource "google_cloudfunctions2_function" "upload_function" {
  name     = "upload-image"
  location = var.region

  build_config {
    runtime     = "python311"
    entry_point = "upload_image"

    source {
      storage_source {
        bucket = google_storage_bucket.uploads_bucket.name
        object = "upload-function-source.zip"
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60

    service_account_email = google_service_account.function_sa.email
  }
}
# Process Image Function
resource "google_cloudfunctions2_function" "process_function" {
  name     = "process-image"
  location = var.region

  build_config {
    runtime     = "python311"
    entry_point = "process_image"

    source {
      storage_source {
        bucket = google_storage_bucket.uploads_bucket.name
        object = "process-function-source.zip"
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "512M"
    timeout_seconds    = 120

    service_account_email = google_service_account.function_sa.email
  }

  event_trigger {
    event_type = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic = google_pubsub_topic.image_processing_requests.id
  }
}
# Notification Function
resource "google_cloudfunctions2_function" "log_function" {
  name     = "log-notification"
  location = var.region

  build_config {
    runtime     = "python311"
    entry_point = "log_notification"

    source {
      storage_source {
        bucket = google_storage_bucket.uploads_bucket.name
        object = "log-function-source.zip"
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60

    service_account_email = google_service_account.function_sa.email
  }

  event_trigger {
    event_type  = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic = google_pubsub_topic.image_processing_results.id
  }
}
# API Gateway
resource "google_api_gateway_api" "api" {
  provider = google-beta
  api_id   = "image-processing-api"
}

resource "google_api_gateway_api_config" "api_config" {
  provider      = google-beta
  api           = google_api_gateway_api.api.api_id
  api_config_id = "v1"

  openapi_documents {
    document {
      path     = "openapi.yaml"
      contents = filebase64("openapi.yaml")
    }
  }
}
resource "google_api_gateway_gateway" "gateway" {
  provider   = google-beta
  gateway_id = "image-processing-gateway"
  api_config = google_api_gateway_api_config.api_config.id
  region     = var.region
}



