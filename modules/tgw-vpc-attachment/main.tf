# VPC Attachment Module for Spoke Accounts

# This module sets up VPC attachments to a transit gateway for spoke accounts.

variable "vpc_id" {
  description = "The VPC ID to attach."
  type        = string
}

variable "transit_gateway_id" {
  description = "The ID of the transit gateway."
  type        = string
}

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  transit_gateway_id = var.transit_gateway_id
  vpc_id            = var.vpc_id
  subnet_ids        = var.subnet_ids
  tags = var.tags
}

output "attachment_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.this.id
}