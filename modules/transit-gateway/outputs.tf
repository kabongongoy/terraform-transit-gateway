# Transit Gateway Outputs

output "transit_gateway_id" {
  value = aws_ec2_transit_gateway.example.id
}

output "transit_gateway_arn" {
  value = aws_ec2_transit_gateway.example.arn
}