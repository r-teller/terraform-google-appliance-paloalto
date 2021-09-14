provider "google" {}

terraform {
  required_version = "1.0.0"

  required_providers {
    google      = "3.82.0"
    google-beta = "3.82.0"
  }
}