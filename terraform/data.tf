data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "go-note-api2" {
  bucket = "go-note-api2"
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "s3_bucket" {
  value = data.aws_s3_bucket.go-note-api2.bucket
}
