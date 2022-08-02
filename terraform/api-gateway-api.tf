resource "aws_api_gateway_rest_api" "go-note-api2" {
  name = "go-note-api2"
}

resource "aws_api_gateway_deployment" "go-note-api2" {
  rest_api_id = aws_api_gateway_rest_api.go-note-api2.id
  stage_name  = ""
}

resource "aws_api_gateway_stage" "go-note-api2" {
  depends_on = [
    aws_api_gateway_deployment.go-note-api2
  ]

  stage_name    = "v1"
  rest_api_id   = aws_api_gateway_rest_api.go-note-api2.id
  deployment_id = aws_api_gateway_deployment.go-note-api2.id
}
