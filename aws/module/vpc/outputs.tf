output "vpc-id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}
output "public_subnets_id" {
  value = aws_subnet.apes-public-subnet.*.id
}


output "private_subnets_id" {
  value = aws_subnet.apes-private-subnet.*.id
}


output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.apes-internet-gateway.id
}

output "nat_gw_id" {
  description = "The ID of the NAT Gateway."
  value       = aws_nat_gateway.apes-nat-gateway.id
}

output "nat_gw_connectivity_type" {
  description = "Connectivity type for the gateway. Valid values are private and public."
  value       = aws_nat_gateway.apes-nat-gateway.connectivity_type
}

output "public_route_table_id" {
  description = "The ID of public route table"
  value       = aws_route_table.apes-public-rt.id
}

output "private_route_table_id" {
  description = "The ID of private route table"
  value       = aws_route_table.apes-private-rt.id
}

output "vpc-endpoint-id" {
  description = "The ID of vpc endpoint"
  value       = aws_vpc_endpoint.apes-vpc-endpoint-s3.id
}

output "security_group_id" {
  description = "The ID of security group"
  value       = aws_security_group.apes-sg.id
}

output "eip_id"{
 description = "Elastic ip for Medialive VPC"
 value = aws_eip.eni.id
}

output "eip-nat" {
 description = "Elastic ip for Nat Gateway"
  value = aws_eip.nat.id
}
