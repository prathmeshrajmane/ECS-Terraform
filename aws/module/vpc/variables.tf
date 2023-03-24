variable "vpc-name"               {}
variable "vpc-cidr"               {}
variable "public-cidr"            {}
variable "public-subnet-name"     {}
variable "public-subnets-cidr"    {}
variable "private-subnet-name"    {}
variable "private-subnets-cidr"   {}
variable "env_name" {
  
}
variable "tags"                   {}
variable "instanceTenancy"        {}
variable "dnsSupport"             {}
variable "dnsHostNames"           {}
variable "internet-gateway-name"  {}
variable "nat-gateway-name"       {}
variable "natConnectivity"        {}
variable "public-rt-name"         {}
variable "private-rt-name"        {}
variable "apes-sg-name"           {}
variable "vpc-endpoint-name"      {}
# end of variables.tf
variable "azs" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
