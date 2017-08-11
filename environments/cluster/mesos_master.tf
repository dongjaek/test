module "mesos_master" {
  # source = "https://github.com/dongjaek/test/modules/puppet_cluster"
  source = "/Users/davidkim/infrastructure/test/modules/puppet_cluster"

  role = "mesos"
  subrole = "master"
  image = "${var.images["generic"]}"
  dns_alias = "mesos"

  project = "${var.project}"
  zones = "${var.zones}"
  region = "${var.region}"
  network = "${var.network}"
  subnet = "${var.subnet}"
  region_dns_suffix = "${google_dns_managed_zone.region_dns.dns_name}"
  region_dns_zone_name = "${google_dns_managed_zone.region_dns.name}"
}

resource "google_compute_firewall" "mesos_master_allow_self" {
  name    = "mesos-master-allow-self"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_tags = ["mesos-master"]
  target_tags = ["mesos-master"]
}

resource "google_compute_firewall" "zookeeper_scheduler_allow_mesos_master" {
  name    = "zookeeper-scheduler-allow-mesos-master"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    ports    = ["2181"]
  }

  source_tags = ["mesos-master"]
  target_tags = ["zookeeper-application", "zookeeper-scheduler"]
}

resource "google_dns_record_set" "aurora_dns" {
  name = "aurora.${google_dns_managed_zone.region_dns.dns_name}"
  type = "CNAME"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.region_dns.name}"

  rrdatas = [
    "${module.mesos_master.dns_name}"
  ]
}
