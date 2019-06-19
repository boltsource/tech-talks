# Enable the Service Working API to allow Terraform
# to "peer" our Cloud SQL network with the network
# running Google Kubernetes Engine.  Peering connects
# two different cloud networks together so that they act
# as a single network and the servers on each can talk to
# one another, which is what we need if we want our services
# running on Google Kubernetes Engine to be able to talk to
# our Cloud SQL instance
resource "google_project_service" "servicenetworking" {
  service = "servicenetworking.googleapis.com"

  disable_on_destroy         = true
  disable_dependent_services = true
}

# Enable the SQL Component API service so that Terraform
# can create the Cloud SQL instance
resource "google_project_service" "sqlcomponent" {
  service = "sql-component.googleapis.com"

  disable_on_destroy         = true
  disable_dependent_services = true
}

# Enable the SQL Admin API service so that Terraform
# can create our database's first user
resource "google_project_service" "sqladmin" {
  service = "sqladmin.googleapis.com"

  disable_on_destroy         = true
  disable_dependent_services = true
}

# Create an internal static IP for our Cloud SQL instance
# so that our services have a consistent address to connect to
resource "google_compute_global_address" "private_ip_address" {
  provider = google-beta

  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  # Put the private IP on the same network as our Kubernetes
  # cluster that we created before.  This actually references
  # The cluster defined in `gke.tf` by name "main_cluster".
  # Terraform lets us map values in this way, even between deployed
  # and not-yet-deployed infrastructure.
  network       = google_container_cluster.main_cluster.network
}

# Create a Virtual Private Cloud connection between the Private IP
# created above and the Kubernetes cluster
resource "google_service_networking_connection" "private_vpc_connection" {
  # This is a beta feature, so we are referencing the beta provider
  # from `main.tf`
  provider = google-beta

  network                 = google_container_cluster.main_cluster.network
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]

  # Make sure to wait until the ServiceNetworking API component
  # has been fully enabled!  Just like before!
  depends_on = [google_project_service.servicenetworking]
}

# Create the database instance!
resource "google_sql_database_instance" "master" {
  provider         = google-beta
  name             = "cloud-sql-v2"
  region           = "us-central1"
  database_version = "POSTGRES_9_6"

  # Wait for the SQL Admin and SQL Component APIs, as well as the private
  # VPC connection to all be created
  depends_on = [
    google_project_service.sqladmin,
    google_project_service.sqlcomponent,
    google_service_networking_connection.private_vpc_connection,
  ]

  settings {
    # This should be enough to start with
    tier = "db-g1-small"

    ip_configuration {
      # This tells terraform not to create a public IPV4 address
      # so that this database is kept private and only accessible
      # by other components peered into it's network such as GKE
      ipv4_enabled    = "false"
      # Stick it on the same network as Kubernetes
      private_network = google_container_cluster.main_cluster.network
    }
  }
}

# Create our first database user 
resource "google_sql_user" "users" {
  # Use the variable defined in `main.tf` mapped in from 
  # `TF_VAR_sql_username` in `.envrc.secret`
  name     = var.cloud_sql_username
  # Put the user in the database instance we just created
  instance = google_sql_database_instance.master.name
  password = var.cloud_sql_password
}

# Create our first database inside the database instance
resource "google_sql_database" "production" {
  # Name the database "production"
  name     = "production"
  # Stick it in the database instance we just created
  instance = google_sql_database_instance.master.name
}

