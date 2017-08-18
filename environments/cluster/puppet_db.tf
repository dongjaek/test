module "puppet_db" {
  source = "/Users/davidkim/infrastructure/test/modules/puppetdb_cluster"

  role = "puppet"
  subrole = "db"
  image = "${var.images["puppetdb"]}"
  dns_alias = "db.puppet"
  frontend_lb = "db.puppet.lb"
  lb_port = "80"

  project = "${var.project}"
  zones = "${var.zones}"
  region = "${var.region}"
  network = "${var.network}"
  subnet = "${var.subnet}"
  region_dns_suffix = "${google_dns_managed_zone.region_dns.dns_name}"
  region_dns_zone_name = "${google_dns_managed_zone.region_dns.name}"
}

resource "google_compute_firewall" "puppetdb_allow_self" {
  name    = "puppet-db-allow-self"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_tags = ["puppet-db"]
  target_tags = ["puppet-db"]
}

# TODO A large concern is without programmatic logic, we have to include/modify/update etc this firewall rule in the code every single time a new service is created which is painful. Incredibly so. There is no turing complete language support so the ability to bootstrap is bound in tight walls that are difficult to work through. Deployment manager is leagues better in this regard, however it's incomplete in terms of DNS functionality.

# TODO not sure if we need to add firewall rules for bidirectional communication...

# mesos
resource "google_compute_firewall" "puppet_db_allow_mesos" {
  name    = "puppet-db-allow-mesos"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    # TODO For testing open everything, ew. clean this
    # ports    = ["22, 80, 8140"]
    ports    = ["0-65535"]
  }

  source_tags = ["puppet-db"]
  target_tags = ["mesos-application", "mesos-db"]
}

# zookeeper
resource "google_compute_firewall" "puppet_db_allow_zookeeper" {
  name    = "puppet-db-allow-zookeeper"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    # TODO For testing open everything, ew. clean this
    # ports    = ["22, 80, 8140"]
    ports    = ["0-65535"]
  }

  source_tags = ["puppet-db"]
  target_tags = ["zookeeper-application", "zookeeper-scheduler"]
}
