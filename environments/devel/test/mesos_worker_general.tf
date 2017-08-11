module "mesos_worker_general" {
  # TODO replace with github style links, TF_VAR_github_pass
  # https://www.terraform.io/docs/modules/sources.html
  source = "https://github.com/dongjaek/test/modules/puppet_cluster"

  role = "mesos-worker"
  role_override = "mesos.worker"
  subrole = "general"
  image = "${var.images["generic"]}"
  instance_type = "n1-standard-4"

  project = "${var.project}"
  zones = ["${var.zones[0]}"]
  region = "${var.region}"
  network = "${var.network}"
  subnet = "${var.subnet}"
  bootscript_bucket = "${var.buckets["boot_scripts"]}"
  region_dns_suffix = "${google_dns_managed_zone.region_dns.dns_name}"
  region_dns_zone_name = "${google_dns_managed_zone.region_dns.name}"
}

resource "google_compute_firewall" "allow_mesos_worker_self" {
  name    = "mesos-worker-allow-self"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    ports    = ["15000-15999", "5051"]
  }

  target_tags = ["mesos-worker-general"]
  source_tags = ["mesos-worker-general"]
}

resource "google_compute_firewall" "allow_mesos_master_worker" {
  name    = "mesos-worker-allow-master"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    ports    = ["5051"]
  }

  source_tags = ["mesos-master"]
  target_tags = ["mesos-worker-general"]
}

resource "google_compute_firewall" "allow_mesos_worker_master" {
  name    = "mesos-master-allow-worker"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    ports    = ["5050"]
  }

  source_tags = ["mesos-worker-general"]
  target_tags = ["mesos-master"]
}


resource "google_compute_firewall" "allow_worker_to_zookeeper" {
  name    = "zookeeper-allow-mesos-worker-general"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    ports    = ["2181"]
  }

  source_tags = ["mesos-worker-general"]
  target_tags = ["zookeeper-scheduler", "zookeeper-application"]
}
