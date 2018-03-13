output "kubernetes-version" {
  value = "${google_container_cluster.primary.master_version}"
}

output "kubernetes-name" {
  value = "gke_${var.project}_${var.zone}_${google_container_cluster.primary.name}"
}

output "kubernetes-server" {
  value = "https://${google_container_cluster.primary.endpoint}"
}

// need to base64 decode and save as client.pem for the kubectl config
output "kubernetes-client-certificate" {
  value = "${google_container_cluster.primary.master_auth.0.client_certificate}"
}

// need to base64 decode and save as client-key.pem for kubectl config
output "kubernetes-client-key" {
  value = "${google_container_cluster.primary.master_auth.0.client_key}"
}

output "kubernetes-certificate-authority-data" {
  value = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
}

// need to base64 decode and save as JSON for spinnaker config
output "spinnaker-private-key" {
  value = "${google_service_account_key.spinnaker_key.private_key}"
}

output "spinnaker-config-bucket" {
  value = "${google_storage_bucket.spinnaker_config.name}"
}
