# TODO this needs to be programmatically looked up and ferried across instance groups to have update the zones so that we elastically go along with up/fail. not now though
variable "zones" {
  type = "list"
  default = [
    "us-central1-a",
    "us-central1-b",
    "us-central1-c"
  ]
}

variable "lb_ports" {
  default = "1-65535"
}

variable "healthcheck_port" {
  default = "80"
}

# TODO this is decided once XPN is properly configured, for now it doesn't matter
variable "network" {
  default = "default"
}

variable "subnet" {
  default = "default"
}

variable "images" {
  type = "map"
  default = {
    generic = "centos-7"
    puppetmaster = "puppetmaster"
    puppetdb = "puppetdb"
  }
}

# TODO internal dns TLD is twitter.biz, I'd like to stay close to that but we work in a hybrid model right now. How is this going to work with internal DNS and the forwarders? Refactor later
variable "tld" {
  default = "pcs.io"
}

# TODO this needs to be refactored across provider.tf files for configuration
# right now we are pointing at google-us-central-1 (guc1) but long term must be cleaned up.
variable "dc" {
  default = "guc1"
}

# TODO the access of dc:region should be a map and clean to have clear extensibility. Unfortunately terraform is arcance here. Fix later.
variable "region" {
  default = "us-central1"
}

# TODO this tends to flip out when not used exactly how they want it. 
# need to do some symlink works of ./.terraform/ directory structures to
# tie together modules otherwise it goes nuts
/*
terraform {
  backend "s3" {
    bucket = "pcs_state_bucket"
    region = "us-east-1"
    key = "LockID"
    dynamodb_table = "pcs_state_lock"
    encrypt = true
  }
}
*/

# TODO Should have work environments per project, need to refactor this.
variable "project" {
  default = "core-infrastructure-173322"
}

provider "google" {
  # TODO remove this and have a proper delivery mechanism for secrets (passtiche mount /etc/twkeys expectaitons?)
  credentials = "${file("~/workspace/ops-sec/files/pcs/gcp/image-builder/pcs-image-builder.json")}"
  project     = "${var.project}"
  # project = "core-infrastructure-173322"
  region      = "${var.region}"
  # region = "us-central1"
}

provider "aws" {
  region = "us-east-1"
}
