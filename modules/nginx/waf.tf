resource "aws_wafv2_web_acl" "rate_limit" {
  name        = "nginx-rate-limit"
  description = "Rate Limit"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "nginx-rate-limit"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 300
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "nginx-rate-limits"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "nginx_lb"
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_web_acl" "OWASP10" {
  name        = "nginx-OWASP10"
  description = "OWASP10"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "OWASP10"
    priority = 2

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "SizeRestrictions_QUERYSTRING"
        }

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "NoUserAgent_HEADER"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "OWASP10"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "nginx_lb"
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_web_acl_association" "nginx_rate_limit" {
  resource_arn = aws_lb.nginx.arn
  web_acl_arn  = aws_wafv2_web_acl.rate_limit.arn
}

resource "aws_wafv2_web_acl_association" "nginx_OWASP10" {
  resource_arn = aws_lb.nginx.arn
  web_acl_arn  = aws_wafv2_web_acl.OWASP10.arn
}