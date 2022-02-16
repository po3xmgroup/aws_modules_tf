data "aws_s3_bucket" "codepipeline_bucket" {
  bucket = var.s3_bucket_name
}

data "aws_cloudfront_origin_access_identity" "po3xm-testing" {

  id = "E39OBE3O5KW9US"
}


resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name =  data.aws_s3_bucket.codepipeline_bucket.bucket_regional_domain_name
    #aws_s3_bucket.b.bucket_regional_domain_name
    origin_id   = data.aws_cloudfront_origin_access_identity.po3xm-testing.cloudfront_access_identity_path

    s3_origin_config {
      origin_access_identity = data.aws_cloudfront_origin_access_identity.po3xm-testing.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.comment
  default_root_object = "index.html"

  # logging_config {
  #   include_cookies = false
  #   bucket          = "mylogs.s3.amazonaws.com"
  #   prefix          = "myprefix"
  # }

  # aliases = ["mysite2323.example.com", "yoursite23232.example.com"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = data.aws_cloudfront_origin_access_identity.po3xm-testing.cloudfront_access_identity_path

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = data.aws_cloudfront_origin_access_identity.po3xm-testing.cloudfront_access_identity_path

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = data.aws_cloudfront_origin_access_identity.po3xm-testing.cloudfront_access_identity_path

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }


  viewer_certificate {
    cloudfront_default_certificate = true
  }


}



# locals {
#   website_files = fileset(var.website_root, "**")

#   file_hashes = {
#     for filename in local.website_files :
#     filename => filemd5("${var.website_root}/${filename}")
#   }
# }

# resource "null_resource" "invalidate_cache" {
#   triggers = locals.file_hashes

#   provisioner "local-exec" {
#     command = "aws --profile=aws_admin cloudfront create-invalidation --distribution-id=${aws_cloudfront_distribution.s3_distribution.id} --paths=/*"
#   }
# }