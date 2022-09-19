
resource "aws_db_instance" "default" {
  allocated_storage      = var.db_storage
  db_name                = var.db_name
  engine                 = "mysql"
  engine_version         = var.db_ev
  instance_class         = var.instance_class
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = var.db_sfs
  vpc_security_group_ids = var.db_sgi
  db_subnet_group_name   = var.db_sub_group_name
  identifier             = var.db_identifier
  tags = {
    Name = "theo-db"
  }
}
