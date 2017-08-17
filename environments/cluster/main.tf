resource google_dns_managed_zone "region_dns" {
  name = "${var.region}-${var.dc}"
  dns_name = "${var.dc}.${var.tld}."
}
