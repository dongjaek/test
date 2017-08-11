variable "project" {
  default = "core-infrastructure-173322"
}
variable "region" {
  default = "us-central1"
}
variable "zones" {
  type = "list"
  default = [
    "us-central1-a",
    "us-central1-b",
    "us-central1-c"
  ]
}
variable "network" {
  default = "default"
}
variable "subnet" {
  default = "default"
}

variable "team_prefix" {
  default = "pcs"
}

variable "images" {
  type = "map"
  default = {
    generic = "pcs-centos-7"
    puppetmaster = "pcs-puppetmaster"
  }
}

# TODO REPLACE WITH INCLUDE FILE INTO METADATA AND USE STARTUP SCRIPT
variable "buckets" {
  type = "map"
  default = {
    boot_scripts = "tcdc-boot-scripts-devel"
  }
}

variable "tld" {
  default = "pcs.io"
}

variable "dc" {
  default = "guc1"
}

terraform {
  backend "s3" {
    bucket = "pcs_state_bucket"
    region = "us-east-1"
    key = "LockID"
    dynamodb_table = "pcs_state_lock"
    encrypt = true
  }
}

provider "google" {
  credentials = "${file("~/workspace/ops-sec/files/pcs/gcp/image-builder/pcs-image-builder.json")}"
  project     = "${var.project}"
  # project = "core-infrastructure-173322"
  region      = "${var.region}"
  # region = "us-central1"
}

provider "aws" {
  region = "us-east-1"
}
