output "region" {
  value = var.region
}

output "account_id" {
  value = data.external.aws_id.result.value
}
