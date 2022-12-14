resource "aws_iam_role" "go-note-api2" {
  name = "LambdaRole_GoNoteApi2"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {"Service": "lambda.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "go-note-api2" {
  role       = aws_iam_role.go-note-api2.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "go-note-api2" {
  function_name = "go-note-api2"
  role          = aws_iam_role.go-note-api2.arn
  filename      = "../lambda.zip"
  handler       = "main"
  runtime       = "go1.x"
  memory_size   = 1024
  timeout       = 300

  environment {
    variables = {
      APP_ENV = "production"
    }
  }
}

resource "aws_cloudwatch_log_group" "go-note-api2" {
  name = "/aws/lambda/go-note-api2"
}

resource "aws_lambda_permission" "go-note-api2" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.go-note-api2.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:ap-northeast-2:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.go-note-api2.id}/*/*"
}

resource "aws_iam_policy" "go-note-api2-dynamodb" {
  name = "LambdaRole_GoNoteApi2"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:DeleteItem",
        "dynamodb:Scan",
        "dynamodb:Query",
        "dynamodb:UpdateItem",
        "dynamodb:ListTable",
        "dynamodb:DescribeTable",
        "dynamodb:GetItem",
        "dynamodb:DescribeLimits",
        "dynamodb:GetRecords"
      ],
      "Resource": "arn:aws:dynamodb:ap-northeast-2:${data.aws_caller_identity.current.account_id}:table/go-note-api2"
    }
  ]
}    
EOF
}

resource "aws_iam_role_policy_attachment" "go-note-api2-dynamodb" {
  role       = aws_iam_role.go-note-api2.name
  policy_arn = aws_iam_policy.go-note-api2-dynamodb.arn
}
