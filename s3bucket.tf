#######################TARGET-GROUP###########
resource "aws_s3_bucket" "bucket" {
  bucket = "terraformassinmentbucket112"  
  tags = {
    Name        = "bucket"
  }  
}
######################access control list (ACL)###########
resource "aws_s3_bucket_acl" "bucketaceeslist" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}
######################creating static website###########
resource "aws_s3_bucket_website_configuration" "major" {
  bucket = aws_s3_bucket.bucket.bucket

   index_document {
    suffix = "index.html"
  }

  error_document {
    key = "/index.html"
  }
}



