data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "go-note-api2" {
  bucket = "go-note-api2"
}

data "aws_route53_zone" "go-note-api2" {
  name = "mldn.cc"
}

data "aws_acm_certificate" "go-note-api2" {
  domain      = "mldn.cc"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "s3_bucket" {
  value = data.aws_s3_bucket.go-note-api2.bucket
}

