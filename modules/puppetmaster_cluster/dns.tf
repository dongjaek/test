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

# TODO remove when names are codified, instant tech debt.
# Reason is because we have that puppet is set at puppet.guc1.pcs.io but
# dns naming convention is xyz.subrole.role.dc.zone and we have a problem
# because masters are set at master.puppet.guc1.pcs.io and we expect it at
# puppet.guc1.pcs.io
resource "google_dns_record_set" "techdebt" {
  count = "${var.dns_alias != "" ? "1" : "0"}"

  name = "puppet.${var.region_dns_suffix}"
  type = "CNAME"
  ttl  = 300

  managed_zone = "${var.region_dns_zone_name}"

  rrdatas = [
    "${var.dns_alias}.${var.region_dns_suffix}"
  ]
}
