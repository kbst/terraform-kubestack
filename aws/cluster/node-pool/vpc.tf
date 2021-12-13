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

resource "aws_route_table" "current" {
  count = local.vpc_subnet_newbits == null ? 0 : length(local.availability_zones)

  vpc_id = data.aws_vpc.current.id
}

resource "aws_route" "current" {
  count = local.vpc_subnet_newbits == null ? 0 : length(local.availability_zones)

  route_table_id = aws_route_table.current[count.index].id

  gateway_id             = local.vpc_subnet_map_public_ip == false ? null : data.aws_internet_gateway.current[0].id
  nat_gateway_id         = local.vpc_subnet_map_public_ip == false ? data.aws_nat_gateway.current[count.index].id : null
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "current" {
  count = local.vpc_subnet_newbits == null ? 0 : length(local.availability_zones)

  subnet_id      = aws_subnet.current[count.index].id
  route_table_id = aws_route_table.current[count.index].id
}
