variable role {
  default = "mesos"
}

variable subrole {
  default = "master"
}

variable image {
  default = "${var.images["generic"]}"
}

variable dns_alias {
  default = "mesos"
}

variable frontend_lb {
  default = "lb.mesos"
}
