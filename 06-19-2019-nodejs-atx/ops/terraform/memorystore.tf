# Enable the Cloud Memorystore Service API component so that
# Terraform can create the instance
resource "google_project_service" "memorystore" {
  service                     = "redis.googleapis.com"
  disable_on_destroy          = true
  disable_dependent_services  = true
}

# Create the Cloud Memorystore instance
resource "google_redis_instance" "memorystore" {
  name            = "cloud-memorystore"
  tier            = "BASIC"
  # Give it 1GB of ram
  memory_size_gb  = 1
  # Make sure that the Cloud Memorystore Service API is enabled first!
  depends_on      = [google_project_service.memorystore]
  # Stick it in Iowa like everything else
  location_id     = "us-central1-a"
}

