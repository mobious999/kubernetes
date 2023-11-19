vpc_cidr_block = "10.0.0.0/16"

availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]

private_subnet_cidr_blocks   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnet_cidr_blocks    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
data_subnet_cidr_blocks      = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
caching_subnet_cidr_blocks   = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]

transit_gateway_id = "tgw-0123456789abcdef0"  # Replace with your Transit Gateway ID
