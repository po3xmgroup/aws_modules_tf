resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = var.s3_bucket_name
  acl    = "private"
  force_destroy = true
  policy = templatefile("../../templates/${var.policy_path}", { aws_s3_bucket = "${var.s3_bucket_name}" })

  website {
    index_document = "index.html"
    error_document = "error.html"


  }
  
}