resource "aws_vpc" "current" {
  cidr_block = var.vpc_cidr

  tags = local.eks_metadata_tags
}

resource "aws_subnet" "current" {
  count = length(var.availability_zones)

  availability_zone       = var.availability_zones[count.index]
  cidr_block              = cidrsubnet(aws_vpc.current.cidr_block, var.vpc_subnet_newbits, count.index)
  vpc_id                  = aws_vpc.current.id
  map_public_ip_on_launch = true

  tags = local.eks_metadata_tags
}

resource "aws_internet_gateway" "current" {
  vpc_id = aws_vpc.current.id

  tags = local.eks_metadata_tags
}

resource "aws_route_table" "current" {
  vpc_id = aws_vpc.current.id
}

resource "aws_route" "current" {
  route_table_id = aws_route_table.current.id

  gateway_id             = aws_internet_gateway.current.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "current" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.current[count.index].id
  route_table_id = aws_route_table.current.id
}
