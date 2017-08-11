provider "aws" {
  region = "us-east-1" 
}

variable "bucket_name" {
  default = "pcs_state_bucket"
}

variable "table_name" {
  default = "pcs_state_lock"
}

variable "environment" {
 default = "devel"
}

variable "database_name" {
  default = "terraboard_db"
}

# variable "database_password" {}
# variable "database_username" {}
