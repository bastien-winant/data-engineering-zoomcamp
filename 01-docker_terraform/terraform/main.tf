terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.72.1"
    }
  }
}

provider "google" {
  credentials = "./creds/service-account-creds.json"
  project     = "spatial-thinker-484214-n8"
  region      = "europe-west1"
}

resource "google_storage_bucket" "demo_bucket" {
  name          = "terraform-demo-bucket-spatial-thinker-484214-n8"
  location      = "europe-west1"
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