resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "terraform-${var.cluster_name}/PublicRouteTable"
  }
}

resource "aws_route_table" "PrivateRouteTable" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "terraform-${var.cluster_name}/PrivateRouteTable"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count = 3
  # splat syntax
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = 3
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = aws_route_table.PrivateRouteTable.id
}
