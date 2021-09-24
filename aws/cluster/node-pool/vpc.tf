resource "aws_vpc_ipv4_cidr_block_association" "current" {
  count = local.vpc_secondary_cidr == null ? 0 : 1

  vpc_id     = data.aws_vpc.current.id
  cidr_block = local.vpc_secondary_cidr
}

locals {
  subnet_cidr = length(aws_vpc_ipv4_cidr_block_association.current) == 1 ? aws_vpc_ipv4_cidr_block_association.current[0].cidr_block : data.aws_vpc.current.cidr_block
}

resource "aws_subnet" "current" {
  count = local.vpc_subnet_newbits == null ? 0 : length(local.availability_zones)

  availability_zone = local.availability_zones[count.index]
  cidr_block = cidrsubnet(
    local.subnet_cidr,
    local.vpc_subnet_newbits,
    local.vpc_subnet_number_offset + count.index
  )
  vpc_id                  = data.aws_vpc.current.id
  map_public_ip_on_launch = local.vpc_subnet_map_public_ip == null ? true : local.vpc_subnet_map_public_ip

  tags = data.aws_eks_node_group.default.tags
}

resource "aws_route_table_association" "current" {
  count = local.vpc_subnet_newbits == null ? 0 : length(local.availability_zones)

  subnet_id      = aws_subnet.current[count.index].id
  route_table_id = data.aws_route_table.current.id
}
