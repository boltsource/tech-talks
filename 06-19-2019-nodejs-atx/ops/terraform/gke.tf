# Create a Container API resource 
# to enable the functionality needed to 
# actually create a Kubernetes cluster
resource "google_project_service" "kubernetes" {
  # This is the API name that we want to enable
  service = "container.googleapis.com"

  # When we destroy our infrastructure, disable this API resource rather 
  # than destroying it
  disable_on_destroy         = true
  # If we disable this API, we should also go ahead and disable any other services
  # that depend on it to avoid creating a technical circus and wasting a bunch
  # of time debugging it
  disable_dependent_services = true
}

# Create the Kubernetes cluster
resource "google_container_cluster" "main_cluster" {
  # Let's name it "main-cluster"
  name               = "main-cluster"
  # The depends_on here bit here tells Terraform to WAIT! and make sure that
  # the Container API resource defined above is fully created
  # before we try to create the cluster.  Otherwise, we will
  # get an error because the very API needed to create the cluster
  # won't yet be enabled
  depends_on         = [google_project_service.kubernetes]
  
  # We want Terraform to create 3 VMs for us to run our containers
  initial_node_count = 3

  # We want our VMs to run in chosen region, us-central1-a
  location           = "us-central1-a"

  # We set null fields here because we don't need auth
  master_auth {
    username = ""
    password = ""
  }

  # We want to use IP Aliases so that
  # this is a VPC-native cluster which makes
  # connecting to our database later much easier
  ip_allocation_policy {
    use_ip_aliases = true
  }

  # Here, we describe what we want each VM to have
  node_config {
    # We want each VM to be a n1-standard-2 node.  
    # See Google Compute Pricing for more information, but this
    # ensures that each VM has two CPUs, because Kubernetes itself
    # will end up using a good portion of one of them so we need a
    # seperate CPU for our actual containers
    machine_type = "n1-standard-2"

    # These are the various access permissions our VM needs for our GitChat project
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute", # Talk to the Compute engine
      "https://www.googleapis.com/auth/devstorage.read_only", # Read storage stuff
      "https://www.googleapis.com/auth/logging.write", # For Stackdriver Logging
      "https://www.googleapis.com/auth/monitoring", # For Stackdriver Monitoring
      "https://www.googleapis.com/auth/cloud-platform", # For Stackdriver Error Tracking
      "https://www.googleapis.com/auth/trace.append" # For Stackdriver Trace
    ]

    # Tags to make searching convenient
    tags = ["gke-cluster"]
  }
}