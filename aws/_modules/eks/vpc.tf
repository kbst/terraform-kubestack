resource "aws_vpc" "current" {
  cidr_block = "10.0.0.0/16"

  tags = local.eks_metadata_tags
}

resource "aws_subnet" "current" {
  count = length(var.availability_zones)

  availability_zone = var.availability_zones[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.current.id

  tags = local.eks_metadata_tags
}

resource "aws_internet_gateway" "current" {
  vpc_id = aws_vpc.current.id

  tags = local.eks_metadata_tags
}

resource "aws_route_table" "current" {
  vpc_id = aws_vpc.current.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.current.id
  }
}

resource "aws_route_table_association" "current" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.current[count.index].id
  route_table_id = aws_route_table.current.id
}

