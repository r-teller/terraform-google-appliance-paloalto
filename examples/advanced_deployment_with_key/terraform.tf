provider "google" {}

terraform {
  required_version = "1.0.0"

  required_providers {
    google      = "3.82.0"
    google-beta = "3.82.0"
  }

  # The storage bucket needs to be created before it can be used here in the backend
  # backend "gcs" {
  #   bucket = "bucket-name-goes-here"
  #   prefix = "gcp-terraform-network/shared-vpc-restricted-subnets/__HOST_PROJECT_ID__"
  # }
}