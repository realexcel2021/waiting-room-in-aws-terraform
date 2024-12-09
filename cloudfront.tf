resource "aws_cloudfront_distribution" "public_api_cloudfront" {
  enabled = true
  comment = "CDN for Waiting Room Public API"

  origin {
    domain_name = "${aws_api_gateway_rest_api.public_waiting_room_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com"
    origin_id   = "waiting-room-public-api"

    # custom_origin_config {
    #   origin_protocol_policy = "https-only"
    #   origin_ssl_protocols   = ["TLSv1.2"]
    # }

    custom_header {
      name  = "x-api-key"
      value = ""
    }

    origin_path = "/dev"
  }

  default_cache_behavior {
    target_origin_id       = "waiting-room-public-api"
    viewer_protocol_policy = "https-only"

    allowed_methods = ["HEAD", "GET", "OPTIONS", "PUT", "PATCH", "POST", "DELETE"]
    cached_methods  = ["HEAD", "GET", "OPTIONS"]

    cache_policy_id            = aws_cloudfront_cache_policy.cache_policy.id
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.origin_request_policy.id
    compress                   = true
  }

  ordered_cache_behavior {
    path_pattern           = "/queue_num"
    target_origin_id       = "waiting-room-public-api"
    viewer_protocol_policy = "https-only"

    allowed_methods = ["HEAD", "GET", "OPTIONS", "PUT", "PATCH", "POST", "DELETE"]
    cached_methods  = ["HEAD", "GET", "OPTIONS"]

    cache_policy_id            = aws_cloudfront_cache_policy.event_request_max_cache_policy.id
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.origin_request_policy.id
    compress                   = true
  }

  ordered_cache_behavior {
    path_pattern           = "/queue_pos_expiry"
    target_origin_id       = "waiting-room-public-api"
    viewer_protocol_policy = "https-only"

    allowed_methods = ["HEAD", "GET", "OPTIONS", "PUT", "PATCH", "POST", "DELETE"]
    cached_methods  = ["HEAD", "GET", "OPTIONS"]

    cache_policy_id            = aws_cloudfront_cache_policy.queue_position_expiry_cache_policy.id
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.origin_request_policy.id
    compress                   = true
  }

  ordered_cache_behavior {
    path_pattern           = "/public_key"
    target_origin_id       = "waiting-room-public-api"
    viewer_protocol_policy = "https-only"

    allowed_methods = ["HEAD", "GET", "OPTIONS", "PUT", "PATCH", "POST", "DELETE"]
    cached_methods  = ["HEAD", "GET", "OPTIONS"]

    cache_policy_id            = aws_cloudfront_cache_policy.event_max_cache_policy.id
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.origin_request_policy.id
    compress                   = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_origin_request_policy" "origin_request_policy" {
  name = "${var.project_name}-OriginRequestPolicy"

  cookies_config {
    cookie_behavior = "none"
  }

  headers_config {
    header_behavior = "none"
  }

  query_strings_config {
    query_string_behavior = "all"
  }
}

resource "aws_cloudfront_cache_policy" "cache_policy" {
  name = "${var.project_name}-CachePolicy"

  default_ttl = 5
  max_ttl     = 5
  min_ttl     = 1

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "whitelist"
      query_strings       {
        items = ["event_id"]
      }
    }
  }
}

resource "aws_cloudfront_cache_policy" "queue_position_expiry_cache_policy" {
  name = "${var.project_name}-QposExpCachePolicy"

  default_ttl = 5
  max_ttl     = 5
  min_ttl     = 1

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "whitelist"
      query_strings         {
        items = ["event_id", "request_id"]
      }
    }
  }
}

resource "aws_cloudfront_cache_policy" "event_max_cache_policy" {
  name = "${var.project_name}-EventMaxCachePolicy"

  default_ttl = 86400
  max_ttl     = 31536000
  min_ttl     = 1

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "whitelist"
      query_strings         {
        items = ["event_id"]
      }
    }
  }
}

resource "aws_cloudfront_cache_policy" "event_request_max_cache_policy" {
  name = "${var.project_name}-EventRequestMaxCachePolicy"

  default_ttl = 86400
  max_ttl     = 31536000
  min_ttl     = 1

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "whitelist"
      query_strings         {
        items = ["event_id", "request_id"]
      }
    }
  }
}


