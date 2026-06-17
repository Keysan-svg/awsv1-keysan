data "aws_subnets" "vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

locals {
  selected_subnet_id = sort(data.aws_subnets.vpc_subnets.ids)[0]
}