variable "project_id" {
  type        = string
  default     = "spatial-thinker-484214-n8"
  description = "GCP project ID"
}

variable "service-account-key" {
  description = "Service account key file location"
  default = "./creds/service-account-creds.json"
}

variable "project_location" {
  type        = string
  default     = "europe-west1"
  description = "Default location for project resources"
}

variable "bucket_name" {
  type        = string
  default     = "terraform-demo-bucket-spatial-thinker-484214-n8"
  description = "GCS bucket name"
}

variable "dataset_id" {
  type        = string
  default     = "demo_bigquery_dataset"
  description = "GCS bucket name"
}