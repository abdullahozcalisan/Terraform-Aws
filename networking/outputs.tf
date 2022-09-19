output "sec_grop_id" {
  value = aws_security_group.theo["priv"].id
}

output "pub_sec_gr" {
  value = aws_security_group.theo["public"].id
}

output "db_sub_g" {
  value = aws_db_subnet_group.theo_db_sub.*.name
}

output "pub_sub_id" {
  value = aws_subnet.theo_pub_sub.*.id
}

output "vpc_id" {
  value = aws_vpc.theo_vpc.id
}
