provider "aws" {
  region = "us-west-2"  # Update with your desired region
}

# Load variables from tfvars file
locals {
  vpc_cidr_block              = var.vpc_cidr_block
  availability_zones          = var.availability_zones
  private_subnet_cidr_blocks  = var.private_subnet_cidr_blocks
  public_subnet_cidr_blocks   = var.public_subnet_cidr_blocks
  data_subnet_cidr_blocks     = var.data_subnet_cidr_blocks
  caching_subnet_cidr_blocks  = var.caching_subnet_cidr_blocks
  transit_gateway_id          = var.transit_gateway_id
}

resource "aws_vpc" "main" {
  cidr_block = local.vpc_cidr_block

  tags = {
    Name = "MyVPC"
  }
}

resource "aws_subnet" "private" {
  count = length(local.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.private_subnet_cidr_blocks[count.index]
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "private-${local.availability_zones[count.index]}"
  }
}

resource "aws_subnet" "public" {
  count = length(local.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.public_subnet_cidr_blocks[count.index]
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-${local.availability_zones[count.index]}"
  }
}

resource "aws_subnet" "data" {
  count = length(local.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.data_subnet_cidr_blocks[count.index]
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "data-${local.availability_zones[count.index]}"
  }
}

resource "aws_subnet" "caching" {
  count = length(local.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.caching_subnet_cidr_blocks[count.index]
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "caching-${local.availability_zones[count.index]}"
  }
}

resource "aws_route_table" "private" {
  count = length(local.availability_zones)

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-${local.availability_zones[count.index]}"
  }
}

resource "aws_route_table" "public" {
  count = length(local.availability_zones)

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-${local.availability_zones[count.index]}"
  }
}

resource "aws_route_table" "data" {
  count = length(local.availability_zones)

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "data-${local.availability_zones[count.index]}"
  }
}

resource "aws_route_table" "caching" {
  count = length(local.availability_zones)

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "caching-${local.availability_zones[count.index]}"
  }
}

resource "aws_route" "private" {
  count = length(local.availability_zones)

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"  # Add your private route destinations if needed
}

resource "aws_route" "public" {
  count = length(local.availability_zones)

  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"  # Add your public route destinations if needed

  # Transit Gateway route
  transit_gateway_id = local.transit_gateway_id
}

resource "aws_route" "data" {
  count = length(local.availability_zones)

  route_table_id         = aws_route_table.data[count.index].id
  destination_cidr_block = "0.0.0.0/0"  # Add your data route destinations if needed

  # Transit Gateway route
  transit_gateway_id = local.transit_gateway_id
}

resource "aws_route" "caching" {
  count = length(local.availability_zones)

  route_table_id         = aws_route_table.caching[count.index].id
  destination_cidr_block = "0.0.0.0/0"  # Add your caching route destinations if needed

  # Transit Gateway route
  transit_gateway_id = local.transit_gateway_id
}

resource "aws_vpc_attachment" "private" {
  count          = length(local.availability_zones)
  vpc_id         = aws_vpc.main.id
  transit_gateway_id = local.transit_gateway_id

  subnet_ids = [aws_subnet.private[count.index].id]
}

resource "aws_vpc_attachment" "public" {
  count          = length(local.availability_zones)
  vpc_id         = aws_vpc.main.id
  transit_gateway_id = local.transit_gateway_id

  subnet_ids = [aws_subnet.public[count.index].id]
}

resource "aws_vpc_attachment" "data" {
  count          = length(local.availability_zones)
  vpc_id         = aws_vpc.main.id
  transit_gateway_id = local.transit_gateway_id

  subnet_ids = [aws_subnet.data[count.index].id]
}

resource "aws_vpc_attachment" "caching" {
  count          = length(local.availability_zones)
  vpc_id         = aws_vpc.main.id
  transit_gateway_id = local.transit_gateway_id

  subnet_ids = [aws_subnet.caching[count.index].id]
}
