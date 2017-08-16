resource "google_compute_region_backend_service" "backend" {
  count = "${var.frontend_lb != "" ? 1 : 0}"

  name                  = "${var.role}-${var.subrole}-lb"
  protocol              = "TCP"
  timeout_sec           = 10

  backend {
    group = "${google_compute_instance_group_manager.group.0.instance_group}"
  }
  backend {
    group = "${google_compute_instance_group_manager.group.1.instance_group}"
  }
  backend {
    group = "${google_compute_instance_group_manager.group.2.instance_group}"
  }

  health_checks = ["${google_compute_health_check.default.self_link}"]
}

resource "google_compute_health_check" "default" {
  count = "${var.frontend_lb != "" ? 1 : 0}"

  name               = "${var.role}-${var.subrole}-healthcheck"
  check_interval_sec = 1
  timeout_sec        = 1
  tcp_health_check {
    port = "${var.lb_port}"
  }
}

resource "google_compute_firewall" "allow_healthcheck" {
  count = "${var.frontend_lb != "" ? 1 : 0}"

  name    = "${var.role}-${var.subrole}-allow-hc"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    ports    = ["${var.lb_port}"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags = ["${var.role}-${var.subrole}"]
}

resource "google_compute_forwarding_rule" "default" {
  count = "${var.frontend_lb != "" ? 1 : 0}"

  name       = "${var.role}-${var.subrole}-forwarding-rule"
  load_balancing_scheme = "INTERNAL"

  backend_service = "${google_compute_region_backend_service.backend.self_link}"
  ports = ["80"]
  subnetwork = "https://www.googleapis.com/compute/v1/projects/${var.project}/regions/${var.region}/subnetworks/${var.subnet}"
  network = "https://www.googleapis.com/compute/v1/projects/${var.project}/global/networks/${var.network}"
}

resource "google_dns_record_set" "lbdns" {
  count = "${var.frontend_lb != "" ? 1 : 0}"

  name = "${var.frontend_lb}.${var.region_dns_suffix}"
  type = "A"
  ttl  = 300

  managed_zone = "${var.region_dns_zone_name}"

  rrdatas = [
    "${google_compute_forwarding_rule.default.ip_address}"
  ]
}
