resource "aws_vpc" "current" {
  cidr_block = local.cluster_vpc_cidr

  enable_dns_hostnames = local.cluster_vpc_dns_hostnames
  enable_dns_support   = local.cluster_vpc_dns_support

  tags = local.eks_metadata_tags
}

resource "aws_subnet" "current" {
  count = length(local.cluster_availability_zones)

  availability_zone       = local.cluster_availability_zones[count.index]
  cidr_block              = cidrsubnet(aws_vpc.current.cidr_block, local.cluster_vpc_control_subnet_newbits, count.index)
  vpc_id                  = aws_vpc.current.id
  map_public_ip_on_launch = local.cluster_vpc_subnet_map_public_ip

  tags = local.eks_metadata_tags
}

resource "aws_subnet" "node_pool" {
  count = local.cluster_vpc_legacy_node_subnets ? 0 : length(local.cluster_availability_zones)

  availability_zone       = local.cluster_availability_zones[count.index]
  cidr_block              = cidrsubnet(aws_vpc.current.cidr_block, local.cluster_vpc_node_subnet_newbits, local.cluster_vpc_node_subnet_number_offset + count.index)
  vpc_id                  = aws_vpc.current.id
  map_public_ip_on_launch = local.cluster_vpc_subnet_map_public_ip

  tags = local.eks_metadata_tags
}

resource "aws_internet_gateway" "current" {
  vpc_id = aws_vpc.current.id

  tags = local.eks_metadata_tags
}

resource "aws_eip" "nat_gw" {
  count = local.cluster_vpc_subnet_map_public_ip == false ? length(local.cluster_availability_zones) : 0

  tags = local.eks_metadata_tags

  domain = "vpc"
}

resource "aws_nat_gateway" "current" {
  count = local.cluster_vpc_subnet_map_public_ip == false ? length(local.cluster_availability_zones) : 0

  allocation_id = aws_eip.nat_gw[count.index].id
  subnet_id     = aws_subnet.current[count.index].id

  tags = merge(
    local.eks_metadata_tags,
    { "kubestack.com/cluster_provider_zone" = local.cluster_availability_zones[count.index] }
  )

  depends_on = [aws_internet_gateway.current]
}

resource "aws_route_table" "current" {
  count = length(local.cluster_availability_zones)

  vpc_id = aws_vpc.current.id
}

resource "aws_route" "current" {
  count = length(local.cluster_availability_zones)

  route_table_id = aws_route_table.current[count.index].id

  gateway_id             = aws_internet_gateway.current.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "current" {
  count = length(local.cluster_availability_zones)

  subnet_id      = aws_subnet.current[count.index].id
  route_table_id = aws_route_table.current[count.index].id
}

resource "aws_route_table" "node_pool" {
  count = length(local.cluster_availability_zones)

  vpc_id = aws_vpc.current.id
}

resource "aws_route" "node_pool" {
  count = length(local.cluster_availability_zones)

  route_table_id = aws_route_table.node_pool[count.index].id

  gateway_id             = local.cluster_vpc_subnet_map_public_ip == false ? null : aws_internet_gateway.current.id
  nat_gateway_id         = local.cluster_vpc_subnet_map_public_ip == false ? aws_nat_gateway.current[count.index].id : null
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "node_pool" {
  count = local.cluster_vpc_legacy_node_subnets ? 0 : length(local.cluster_availability_zones)

  subnet_id      = aws_subnet.node_pool[count.index].id
  route_table_id = aws_route_table.node_pool[count.index].id
}
