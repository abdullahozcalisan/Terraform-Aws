data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20220610"]
  }
}



resource "random_id" "theo_id" {
  byte_length = 2
  count       = var.instance_count
  keepers = {
    key_name = var.key_name
  }
}

resource "aws_instance" "theo_node" {
  count                  = var.instance_count
  instance_type          = var.instance_type
  ami                    = data.aws_ami.server_ami.id
  key_name               = var.key_name
  vpc_security_group_ids = var.vpc_sg_id
  subnet_id              = var.sub_id[count.index]
  user_data = templatefile(var.user_data_path,
    {
      nodename    = "${random_id.theo_id[count.index].dec}"
      dbname      = var.db_name
      db_endpoint = var.db_endpoint
      dbuser      = var.db_username
      dbpass      = var.db_password

    }
  )
  root_block_device {
    volume_size = var.vol_size

  }
}

resource "aws_lb_target_group_attachment" "theo-tg-attachment" {
  count            = var.instance_count
  target_group_arn = var.tg_arn
  target_id        = aws_instance.theo_node[count.index].id
  port             = var.tga_port
}