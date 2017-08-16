module "puppet_master" {
  source = "/Users/davidkim/infrastructure/test/modules/puppetmaster_cluster"

  role = "puppet"
  subrole = "master"
  image = "${var.images["puppetmaster"]}"
  dns_alias = "puppet"

  project = "${var.project}"
  zones = "${var.zones}"
  region = "${var.region}"
  network = "${var.network}"
  subnet = "${var.subnet}"
  region_dns_suffix = "${google_dns_managed_zone.region_dns.dns_name}"
  region_dns_zone_name = "${google_dns_managed_zone.region_dns.name}"
}

resource "google_compute_firewall" "puppetmaster_allow_self" {
  name    = "puppet-master-allow-self"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_tags = ["puppet-master"]
  target_tags = ["puppet-master"]
}

# TODO A large concern is without programmatic logic, we have to include/modify/update etc this firewall rule in the code every single time a new service is created which is painful. Incredibly so. There is no turing complete language support so the ability to bootstrap is bound in tight walls that are difficult to work through. Deployment manager is leagues better in this regard, however it's incomplete in terms of DNS functionality.

# TODO not sure if we need to add firewall rules for bidirectional communication...

# mesos
resource "google_compute_firewall" "puppet_master_allow_mesos" {
  name    = "puppet-master-allow-mesos"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    # TODO For testing open everything, ew. clean this
    # ports    = ["22, 80, 8140"]
    ports    = ["0-65535"]
  }

  source_tags = ["puppet-master"]
  target_tags = ["mesos-application", "mesos-master"]
}

# zookeeper
resource "google_compute_firewall" "puppet_master_allow_zookeeper" {
  name    = "puppet-master-allow-zookeeper"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    # TODO For testing open everything, ew. clean this
    # ports    = ["22, 80, 8140"]
    ports    = ["0-65535"]
  }

  source_tags = ["puppet-master"]
  target_tags = ["zookeeper-application", "zookeeper-scheduler"]
}

resource "google_dns_record_set" "puppet_master_dns" {
  name = "puppet.${google_dns_managed_zone.region_dns.dns_name}"
  type = "CNAME"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.region_dns.name}"

  rrdatas = [
    "${module.puppet_master.dns_name}"
  ]
}
