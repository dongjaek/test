# Variable interpolation is not possible so instead we have to use data
# and then fix everything together with variables and attribute accesses.
# usage is as "${data.template_file.boot.template}"
data "template_file" "puppetmaster_boot" {
  # TODO fix this filepath be root
  template = "${file("~/infrastructure/test/resources/puppetmaster_boot.py")}"
}
data "template_file" "puppetmaster_passtiche" {
  template = "${file("~/infrastructure/test/resources/puppetmaster_passtiche.sh")}"
}
data "template_file" "puppetmaster_init" {
  template = "${file("~/infrastructure/test/resources/puppetmaster_init.sh")}"
}

resource "google_compute_instance_template" "template" {
  name_prefix = "pcs-${var.role}-${var.subrole}-"
  tags = ["${var.role}-${var.subrole}"]
  machine_type = "${var.instance_type}"
  region = "${var.region}"

  disk {
    source_image = "${var.image}"
    auto_delete = true
    boot = true
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  network_interface {
    subnetwork = "${var.subnet}",
    subnetwork_project = "${var.project}"
    access_config {}
  }

  metadata =
  "${
    merge(
      map(
        "tw_region", "${var.dc}",
        "tw_tld", "${var.tld}",
        "puppet_role", "${coalesce("${var.role_override}", "${var.role}")}",
        "puppet_subrole", "${var.subrole}",
        "puppet_environment", "${var.environment}",
        "startup-script", "${data.template_file.puppetmaster_boot.template}",
        "script-puppetmaster_passtiche", "${data.template_file.puppetmaster_passtiche.template}",
        "script-puppetmaster_init", "${data.template_file.puppetmaster_init.template}"
      ),
      map(
        "${var.dns_alias != "" ? "dns-alias" : "no-dns-alias" }", "${var.role}_${var.subrole}"
      )
    )
  }"

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group_manager" "group" {
  count = "${length(var.zones)}"
  name = "pcs-${var.role}-${var.subrole}-${element(var.zones, count.index)}"

  base_instance_name = "pcs-${var.role}-${var.subrole}-${element(var.zones, count.index)}"
  instance_template  = "${google_compute_instance_template.template.self_link}"
  update_strategy    = "NONE"
  zone               = "${element(var.zones, count.index)}"

  target_size  = 1
}
