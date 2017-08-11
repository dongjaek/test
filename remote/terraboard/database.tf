# https://www.terraform.io/docs/providers/aws/r/db_instance.html

resource "aws_db_instance" "terraboard" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "postgresql"
  instance_class       = "db.t1.micro"
  name                 = "${var.database_name}"
  username             = "${var.database_username}"
  password             = "${var.database_password}"
}
