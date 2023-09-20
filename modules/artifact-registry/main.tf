resource "google_artifact_registry_repository" "my-repo" {
  project       = var.project_id
  location      = "europe-west1"
  repository_id = var.repository_name
  description   = "Test repository"
  format        = "DOCKER"
}
