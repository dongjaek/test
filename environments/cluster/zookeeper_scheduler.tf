module "zookeeper_scheduler" {
  source = "/Users/davidkim/infrastructure/test/modules/puppet_cluster"

  role = "zookeeper"
  subrole = "scheduler"
  image = "${var.images["generic"]}"
  dns_alias = "scheduler.zk"
  frontend_lb = "schedulerui.zk"
  lb_port = "80"

  project = "${var.project}"
  zones = "${var.zones}"
  region = "${var.region}"
  network = "${var.network}"
  subnet = "${var.subnet}"
  region_dns_suffix = "${google_dns_managed_zone.region_dns.dns_name}"
  region_dns_zone_name = "${google_dns_managed_zone.region_dns.name}"
}

