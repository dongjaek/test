module "puppetdb" {
  source = "/Users/davidkim/infrastructure/test/modules/puppetdb"

  role = "puppetdb"
  subrole = "base"
  image = "${var.images["puppetdb"]}"
  dns_alias = "puppetdb"
  frontend_lb = "lb.puppetdb"

  instance_type = "n1-standard-8"

  project = "${var.project}"
  zones = "${var.zones}"
  region = "${var.region}"
  network = "${var.network}"
  subnet = "${var.subnet}"
  region_dns_suffix = "${google_dns_managed_zone.region_dns.dns_name}"
  region_dns_zone_name = "${google_dns_managed_zone.region_dns.name}"
}
