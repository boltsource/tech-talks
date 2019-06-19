# Take in the project id from user input or
# an environment variable
variable "project_id" {
  type        = string
  description = "The project id on GCP"
}

# Take in the username for our future SQL database
# from user input or an environment variable
variable "cloud_sql_username" {
  type        = string
  description = "The username for the cloud sql instance"
  default     = "user"
}

# Take in the password for our future SQL database from
# user input or an environment variable
variable "cloud_sql_password" {
  type        = string
  description = "The password for the cloud sql instance"
}