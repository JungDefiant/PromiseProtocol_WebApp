provider "aws" {}

resource "aws_s3_bucket" "example" {
  bucket = "my-test-bucket-350"

  tags = {
    Name = "Test bucket"
  }
}
