resource "aws_vpc_ipv4_cidr_block_association" "current" {
  count = local.cfg.vpc_secondary_cidr == null ? 0 : 1

  vpc_id     = var.cluster.vpc_config[0].vpc_id
  cidr_block = local.cfg.vpc_secondary_cidr
}

locals {
  subnet_cidr = length(aws_vpc_ipv4_cidr_block_association.current) == 1 ? aws_vpc_ipv4_cidr_block_association.current[0].cidr_block : data.aws_vpc.cluster.cidr_block
}

resource "aws_subnet" "current" {
  count = local.cfg.vpc_subnet_newbits != null && local.cfg.availability_zones != null ? length(local.cfg.availability_zones) : 0

  availability_zone = local.cfg.availability_zones[count.index]
  cidr_block = cidrsubnet(
    local.subnet_cidr,
    local.cfg.vpc_subnet_newbits,
    (local.cfg.vpc_subnet_number_offset == null ? 1 : local.cfg.vpc_subnet_number_offset) + count.index
  )
  vpc_id                  = var.cluster.vpc_config[0].vpc_id
  map_public_ip_on_launch = local.cfg.vpc_subnet_map_public_ip == null ? true : local.cfg.vpc_subnet_map_public_ip

  tags = merge(
    { "kubernetes.io/cluster/${var.cluster.name}" = "shared" },
    var.cluster_metadata.labels,
    coalesce(local.cfg.tags, {})
  )
}

resource "aws_route_table" "current" {
  count = local.cfg.vpc_subnet_newbits != null && local.cfg.availability_zones != null ? length(local.cfg.availability_zones) : 0

  vpc_id = var.cluster.vpc_config[0].vpc_id
}

resource "aws_route" "current" {
  count = local.cfg.vpc_subnet_newbits != null && local.cfg.availability_zones != null ? length(local.cfg.availability_zones) : 0

  route_table_id = aws_route_table.current[count.index].id

  gateway_id             = local.cfg.vpc_subnet_map_public_ip == false ? null : data.aws_internet_gateway.current[0].id
  nat_gateway_id         = local.cfg.vpc_subnet_map_public_ip == false ? data.aws_nat_gateway.current[count.index].id : null
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "current" {
  count = local.cfg.vpc_subnet_newbits != null && local.cfg.availability_zones != null ? length(local.cfg.availability_zones) : 0

  subnet_id      = aws_subnet.current[count.index].id
  route_table_id = aws_route_table.current[count.index].id
}
