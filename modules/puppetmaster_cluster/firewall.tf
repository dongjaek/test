resource "google_compute_firewall" "firewall_allow_tcp" {
  # count = "${var.firewall != "" ? 1: 0}"
  name    = "${var.role}-${var.subrole}-firewall-tcp"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    # TODO make more specfic later
    ports    = ["0-6536"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "firewall_allow_udp" {
  # count = "${var.firewall != "" ? 1: 0}"
  name    = "${var.role}-${var.subrole}-firewall-udp"
  network = "${var.network}"

  allow {
    protocol = "udp"
    # TODO make more specfic later
    ports    = ["0-6536"]
  }
  
  source_ranges = ["0.0.0.0/0"]
}
