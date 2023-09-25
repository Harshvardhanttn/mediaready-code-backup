resource "aws_cloudfront_origin_access_identity" "origin_identity" {
  comment = "access-identity"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.datastore.bucket_regional_domain_name
    origin_id   = var.s3_origin_id

    s3_origin_config {
      origin_access_identity = format("origin-access-identity/cloudfront/%s", aws_cloudfront_origin_access_identity.origin_identity.id)
    }
  }

  enabled             = true
  comment             = "cdn"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.s3_origin_id

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
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  tags = {
    "Name"        = "${var.project_name}-cloudfront-${var.environment_name}"
    "Project"     = var.project_name
    "Environment" = var.environment_name
    "Owner"       = var.owner
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  depends_on = [
    aws_cloudfront_origin_access_identity.origin_identity,
    aws_s3_bucket.datastore
  ]
}