resource google_dns_managed_zone "region_dns" {
  name = "${var.team_prefix}-${var.region}-${var.dc}"
  dns_name = "${var.dc}.${var.tld}."
}
