variable role {
  default = "puppet"
}

variable subrole {
  default = "base"
}

variable image {
  # default = "${var.images["puppetmaster"]}"
  # no interpolations ugh
  default = "puppetmaster"
}

variable dns_alias {
  default = "puppet"
}

variable frontend_lb {
  default = "lb.puppet"
}
