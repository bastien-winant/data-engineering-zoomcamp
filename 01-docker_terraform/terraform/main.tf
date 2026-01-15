terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.16.0"
    }
  }
}

provider "google" {
  credentials = "~/.creds/gcp/terraform-runner.json"
  project     = "spatial-thinker-484214-n8"
  region      = "europe-west3"
}