module "mesos_worker" {
  source = "/Users/davidkim/infrastructure/test/modules/puppet_cluster"

  role = "mesos"
  subrole = "worker"
  image = "${var.images["generic"]}"
  instance_type = "n1-standard-4"

  project = "${var.project}"
  zones = ["${var.zones[0]}"]
  region = "${var.region}"
  network = "${var.network}"
  subnet = "${var.subnet}"
  region_dns_suffix = "${google_dns_managed_zone.region_dns.dns_name}"
  region_dns_zone_name = "${google_dns_managed_zone.region_dns.name}"
}
