resource "aws_api_gateway_resource" "note" {
  rest_api_id = aws_api_gateway_rest_api.go-note-api2.id
  parent_id   = aws_api_gateway_rest_api.go-note-api2.root_resource_id
  path_part   = "note"
}

resource "aws_api_gateway_method" "note" {
  rest_api_id   = aws_api_gateway_rest_api.go-note-api2.id
  resource_id   = aws_api_gateway_resource.note.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "note" {
  rest_api_id             = aws_api_gateway_rest_api.go-note-api2.id
  resource_id             = aws_api_gateway_resource.note.id
  http_method             = aws_api_gateway_method.note.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:ap-northeast-2:lambda:path/2015-03-31/functions/${aws_lambda_function.go-note-api2.arn}/invocations"
}

resource "aws_api_gateway_resource" "note-proxy" {
  rest_api_id = aws_api_gateway_rest_api.go-note-api2.id
  parent_id   = aws_api_gateway_resource.note.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "note-proxy" {
  rest_api_id   = aws_api_gateway_rest_api.go-note-api2.id
  resource_id   = aws_api_gateway_resource.note-proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "note-proxy" {
  rest_api_id             = aws_api_gateway_rest_api.go-note-api2.id
  resource_id             = aws_api_gateway_resource.note-proxy.id
  http_method             = aws_api_gateway_method.note-proxy.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:ap-northeast-2:lambda:path/2015-03-31/functions/${aws_lambda_function.go-note-api2.arn}/invocations"
}
