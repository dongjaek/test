output "security_tag" {
  value = "${google_compute_instance_template.template.tags.0}"
}

output "dns_name" {
  value = "${google_dns_record_set.dns.rrdatas[0]}"
}
