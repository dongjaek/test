module "puppet_loadbalancer" {
  source = "/Users/davidkim/infrastructure/test/modules/loadbalancer"

  frontend_lb = "${var.frontend_lb}"
  subrole = "${var.subrole}"
  role = "${var.role}"
}
