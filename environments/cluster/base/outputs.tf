output dns_zone {
  value = "${google_dns_managed_zone.region_dns.dns_name}"
}
