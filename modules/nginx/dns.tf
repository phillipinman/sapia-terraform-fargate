resource "aws_route53_record" "alias" {
  zone_id = "Z6TOYMTA4RGIW"
  name    = "sapia.phillip-inman.com"
  type    = "A"

  alias {
    name                   = "dualstack.${aws_lb.nginx.dns_name}"
    zone_id                = aws_lb.nginx.zone_id
    evaluate_target_health = true
  }
}
