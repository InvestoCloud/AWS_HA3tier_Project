output "certificate_arn" {
  description = "Validated ACM certificate ARN."
  value       = aws_acm_certificate_validation.this.certificate_arn
}

output "certificate_domain_name" {
  description = "Domain name on the ACM certificate."
  value       = aws_acm_certificate.this.domain_name
}