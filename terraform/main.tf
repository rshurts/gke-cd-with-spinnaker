provider "google" {
  project = "${var.project}"
  version = "~> 1.6"
}

# create a kubernetes engine cluster
resource "google_container_cluster" "primary" {
  name               = "primary"
  zone               = "${var.zone}"
  initial_node_count = 3

  node_config {
    machine_type = "n1-standard-1"

    labels {
      terraform = "true"
    }
  }
}

# create the service account
resource "google_service_account" "spinnaker_account" {
  account_id   = "spinnaker-account"
  display_name = "Spinnaker Account"
}

# bind the storage.admin role to the service account
resource "google_project_iam_binding" "spinnaker_account_storage_admin" {
  project = "${var.project}"
  role    = "roles/storage.admin"

  members = [
    "serviceAccount:${google_service_account.spinnaker_account.email}",
  ]
}

# create the service account key
resource "google_service_account_key" "spinnaker_key" {
  service_account_id = "${google_service_account.spinnaker_account.id}"
}

# create a bucket for spinnaker to store its pipeline configurations
resource "google_storage_bucket" "spinnaker_config" {
  name     = "${var.project}-spinnaker-config"
  location = "${var.region}"

  labels {
    terraform = "true"
  }
}
