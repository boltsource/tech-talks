terraform {
  # Make sure we are using Terraform 0.12!
  required_version = ">= 0.12"
}

# Use all of the normal Google features
provider "google" {
  credentials = file("service-account.json")
  region      = "us-central1"
  project     = var.project_id
}

# Use some of the beta Google features
provider "google-beta" {
  credentials = file("service-account.json")
  region      = "us-central1"
  project     = var.project_id
}