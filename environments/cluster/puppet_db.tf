module "puppet_db" {
  source = "/Users/davidkim/infrastructure/test/modules/puppetdb_cluster"

  role = "puppet"
  subrole = "db"
  image = "${var.images["puppetdb"]}"
  dns_alias = "db.puppet"
  frontend_lb = "lb.db.puppet"
  lb_port = "80"

  project = "${var.project}"
  zones = "${var.zones}"
  region = "${var.region}"
  network = "${var.network}"
  subnet = "${var.subnet}"
  region_dns_suffix = "${google_dns_managed_zone.region_dns.dns_name}"
  region_dns_zone_name = "${google_dns_managed_zone.region_dns.name}"
}
