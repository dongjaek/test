resource "google_dns_record_set" "dns" {
  count = "${var.frontend_lb != "" ? "1" : "0"}"

  name = "${var.dns_alias}.${var.region_dns_suffix}"
  type = "CNAME"
  ttl  = 300

  managed_zone = "${var.region_dns_zone_name}"

  rrdatas = [
     "${var.frontend_lb}.${var.region_dns_suffix}"
  ]
}
