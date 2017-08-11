module "puppetmaster" {
  source = "../puppet_cluster"

  role = "puppet"
  subrole = "master"
  image = "${var.images["puppetmaster"]}"
  dns_alias = "puppet"

  project = "${var.project}"
  zones = "${var.zones}"
  region = "${var.region}"
  network = "${var.network}"
  subnet = "${var.subnet}"
  bootscript_bucket = "${var.buckets["boot_scripts"]}"
  region_dns_suffix = "${google_dns_managed_zone.region_dns.dns_name}"
  region_dns_zone_name = "${google_dns_managed_zone.region_dns.name}"
}

resource "google_compute_firewall" "puppetmaster_allow_self" {
  name    = "puppetmaster-allow-self"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_tags = ["puppet-master"]
  target_tags = ["puppet-master"]
}

# zookeeper
resource "google_compute_firewall" "puppetmaster_allow_puppetmaster" {
  name    = "zookeeper-scheduler-allow-mesos-master"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    ports    = ["2181"]
  }

  source_tags = ["puppet-master"]
  target_tags = ["zookeeper-application", "zookeeper-scheduler"]
}

# TODO A large concern is without programmatic logic, we have to include this firewall rule in the code every single time a new service is created which is pain
# mesos cluster
resource "google_compute_firewall" "puppetmaster_allow_puppetmaster" {
  name    = "zookeeper-scheduler-allow-mesos-master"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    ports    = ["2181"]
  }

  source_tags = ["puppet-master"]
  target_tags = ["zookeeper-application", "zookeeper-scheduler"]
}

resource "google_dns_record_set" "puppetmaster_dns" {
  name = "aurora.${google_dns_managed_zone.region_dns.dns_name}"
  type = "CNAME"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.region_dns.name}"

  rrdatas = [
    "${module.puppetmaster.dns_name}"
  ]
}
