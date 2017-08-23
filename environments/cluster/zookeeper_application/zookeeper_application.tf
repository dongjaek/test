module "zookeeper_application" {
  source = "/Users/davidkim/infrastructure/test/modules/puppet"

  role = "zookeeper"
  subrole = "application"
  image = "${var.images["generic"]}"
  dns_alias = "application.zk"
  frontend_lb = "lb.application.zk"

  instance_type = "n1-standard-8"

  project = "${var.project}"
  zones = "${var.zones}"
  region = "${var.region}"
  network = "${var.network}"
  subnet = "${var.subnet}"
  region_dns_suffix = "${google_dns_managed_zone.region_dns.dns_name}"
  region_dns_zone_name = "${google_dns_managed_zone.region_dns.name}"
}

resource "google_compute_firewall" "zookeeper_application_allow_self" {
  name    = "zookeeper-application-allow-self"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_tags = ["zookeeper-application"]
  target_tags = ["zookeeper-application"]
}
