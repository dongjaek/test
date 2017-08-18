module "puppet_master" {
  source = "/Users/davidkim/infrastructure/test/modules/puppetmaster_cluster"

  role = "puppet"
  subrole = "master"
  image = "${var.images["puppetmaster"]}"
  dns_alias = "puppet"
  frontend_lb = "puppet.lb"
  lb_port = "80"

  project = "${var.project}"
  zones = "${var.zones}"
  region = "${var.region}"
  network = "${var.network}"
  subnet = "${var.subnet}"
  region_dns_suffix = "${google_dns_managed_zone.region_dns.dns_name}"
  region_dns_zone_name = "${google_dns_managed_zone.region_dns.name}"
}
