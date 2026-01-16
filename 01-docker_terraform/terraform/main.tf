terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.72.1"
    }
  }
}

provider "google" {
  credentials = file(var.service-account-key)
  project     = var.project_id
  region      = var.project_location
}

resource "google_storage_bucket" "demo_bucket" {
  name          = var.bucket_name
  location      = var.project_location
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

resource "google_bigquery_dataset" "demo_dataset" {
  dataset_id                 = var.dataset_id
  location                   = var.project_location
  delete_contents_on_destroy = true
}