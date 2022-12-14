resource "aws_api_gateway_domain_name" "go-note-api2" {
  domain_name              = "note-api-test2.mldn.cc"
  regional_certificate_arn = data.aws_acm_certificate.go-note-api2.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_route53_record" "go-note-api2" {
  name    = aws_api_gateway_domain_name.go-note-api2.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.go-note-api2.id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.go-note-api2.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.go-note-api2.regional_zone_id
  }
}

resource "aws_api_gateway_base_path_mapping" "go-note-api2" {
  api_id      = aws_api_gateway_rest_api.go-note-api2.id
  stage_name  = "v1"
  domain_name = aws_api_gateway_domain_name.go-note-api2.domain_name
}

