resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = var.s3_bucket_name
  acl    = "private"
  force_destroy = true
  policy = jsonencode({
    "Id": "bucket_policy_site",
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "bucket_policy_site_main",
        "Action": [
          "s3:GetObject"
        ],
        "Effect": "Allow",
        "Resource": "arn:aws:s3:::s3-static-website-training-dev/*",
        "Principal": {"AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity E39OBE3O5KW9US"}
      }
    ]
  })

  website {
    index_document = "index.html"
    error_document = "error.html"


  }
  
}
