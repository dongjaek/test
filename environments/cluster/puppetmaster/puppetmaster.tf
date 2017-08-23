module "puppetmaster" {
  source = "/Users/davidkim/infrastructure/test/modules/puppetmaster"

  role = "${var.role}"
  subrole = "${var.subrole}"
  image = "${var.image}"
  dns_alias = "${var.dns_alias}"
  frontend_lb = "${var.frontend_lb}"

  instance_type = "n1-standard-8"

  project = "${var.project}"
  zones = "${var.zones}"
  region = "${var.region}"
  network = "${var.network}"
  subnet = "${var.subnet}"
  region_dns_suffix = "${google_dns_managed_zone.region_dns.dns_name}"
  region_dns_zone_name = "${google_dns_managed_zone.region_dns.name}"
}
