module "networking" {
  source          = "./networking"
  max_subnets     = 20
  priv_sub_count  = 2
  vpc_cidr        = var.vpc_cidr
  priv_cidrs      = [for i in range(1, 255, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
  pub_sub_count   = 3
  pub_sub_cidrs   = [for i in range(2, 255, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
  sec_group       = local.sec_group
  db_subnet_group = true

}

module "database" {
  source            = "./database"
  db_storage        = 10
  db_name           = var.db_name
  db_ev             = "5.7"
  instance_class    = "db.t3.micro"
  db_username       = var.db_username
  db_password       = var.db_password
  db_sfs            = true
  db_sgi            = [module.networking.sec_grop_id]
  db_sub_group_name = module.networking.db_sub_g[0]
  db_identifier     = "theo-db"
}


module "compute" {
  source         = "./compute"
  instance_count = var.ins_count
  instance_type  = "t2.micro"
  vpc_sg_id      = [module.networking.pub_sec_gr]
  sub_id         = module.networking.pub_sub_id
  user_data_path = "${path.root}/userdata.tpl"
  db_name        = var.db_name
  db_endpoint    = module.database.db_end
  db_username    = var.db_username
  db_password    = var.db_password
  vol_size       = 10
  key_name       = "tfkp"
  tg_arn = module.loadbalancing.tg_arn
  tga_port = 80
}


module "loadbalancing" {
  source                 = "./loadbalancing"
  pub_sec_gr             = [module.networking.pub_sec_gr]
  pub_sub_id             = module.networking.pub_sub_id
  tg_port                = 8000
  tg_protocol            = "HTTP"
  vpc_id                 = module.networking.vpc_id
  lb_healthy_threshold   = 2
  lb_unhealthy_threshold = 2
  lb_timeout             = 3
  lb_interval            = 30
  listener_port          = 80
  listener_protocol      = "HTTP"
}
