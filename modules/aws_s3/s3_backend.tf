# resource "aws_s3_bucket" "backend_bucket" {
#   bucket = "tf_backend"
#   acl    = "private"
#   force_destroy = true
#   policy = templatefile("../../templates/policy_s3_backend.json", { aws_s3_bucket = "tf_backend" })

#   website {
#     index_document = "index.html"
#     error_document = "error.html"


#   }
  
# }