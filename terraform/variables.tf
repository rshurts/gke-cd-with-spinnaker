variable "project" {
  description = "GCP project id"
  type        = "string"
}

variable "region" {
  description = "GCP region. See https://cloud.google.com/compute/docs/regions-zones/ for more information."
  type        = "string"
}

variable "zone" {
  description = "GCP zone, should be inside the region. See https://cloud.google.com/compute/docs/regions-zones/ for more information."
  type        = "string"
}
