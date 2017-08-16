resource "google_dns_record_set" "dns" {
  count = "${var.dns_alias != "" ? "1" : "0"}"

  name = "${var.dns_alias}.${var.region_dns_suffix}"
  type = "CNAME"
  ttl  = 300

  managed_zone = "${var.region_dns_zone_name}"

  rrdatas = [
    "${google_compute_instance_template.template.metadata["dns-alias"]}.asg.gce.${var.region_dns_suffix}"
  ]
}
