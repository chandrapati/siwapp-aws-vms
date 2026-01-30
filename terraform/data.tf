# data.tf

data "aws_s3_bucket" "flowlogs" {
  bucket = var.s3_bucket_name
}
