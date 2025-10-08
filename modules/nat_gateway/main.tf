# Elastic IPs
resource "aws_eip" "nat" {
  count  = 2
  domain = "vpc"
  tags = { Name = "nat-eip-${count.index + 1}" }
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  count         = 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = var.public_subnet_ids[count.index]
  tags = { Name = "nat-${count.index + 1}" }
}

# Routes to NAT
resource "aws_route" "private_nat" {
  count                  = 2
  route_table_id         = var.private_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}