module "mesos_master" {
  source = "/Users/davidkim/infrastructure/test/modules/puppet_cluster"

  role = "mesos"
  subrole = "master"
  image = "${var.images["generic"]}"
  dns_alias = "master.mesos"
  frontend_lb = "master.mesos.lb"
  lb_port = "80"

  project = "${var.project}"
  zones = "${var.zones}"
  region = "${var.region}"
  network = "${var.network}"
  subnet = "${var.subnet}"
  region_dns_suffix = "${google_dns_managed_zone.region_dns.dns_name}"
  region_dns_zone_name = "${google_dns_managed_zone.region_dns.name}"
}

