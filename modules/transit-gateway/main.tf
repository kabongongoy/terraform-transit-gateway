variable "tgw_name" {
  type        = string
  description = "Name for the Transit Gateway"
}

variable "allowed_account_ids" {
  type        = list(string)
  description = "List of AWS account IDs allowed to attach to the TGW"
}

variable "enable_dns_support" {
  type        = bool
  description = "Enable DNS support in the transit gateway"
  default     = true
}

variable "enable_vpn_ecn_support" {
  type        = bool
  description = "Enable VPN ECN support"
  default     = false
}

# Create the Transit Gateway
resource "aws_ec2_transit_gateway" "main" {
  description                     = var.tgw_name
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = var.enable_dns_support ? "enable" : "disable"
  vpn_ecn_support                 = var.enable_vpn_ecn_support ? "enable" : "disable"
  auto_accept_shared_attachments  = "enable"

  tags = {
    Name = var.tgw_name
  }
}

# Create the main route table for the TGW
resource "aws_ec2_transit_gateway_route_table" "main" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = {
    Name = "${var.tgw_name}-rt-main"
  }
}

# Create RAM resource share to allow other accounts to access the TGW
resource "aws_ram_resource_share" "tgw_share" {
  name                      = "${var.tgw_name}-share"
  allow_external_principals = true

  tags = {
    Name = "${var.tgw_name}-share"
  }
}

# Associate the TGW with the RAM share
resource "aws_ram_resource_association" "tgw" {
  resource_share_arn = aws_ram_resource_share.tgw_share.arn
  resource_arn       = aws_ec2_transit_gateway.main.arn
}

# Invite each specified AWS account to the RAM share
resource "aws_ram_principal_association" "member_accounts" {
  for_each           = toset(var.allowed_account_ids)
  principal          = each.value
  resource_share_arn = aws_ram_resource_share.tgw_share.arn
}