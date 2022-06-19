# Lambda function
resource "aws_lambda_function" "lambda" {
  function_name = "counter_function"
  role          = aws_iam_role.iam_lambda.arn
  filename = "lambda/lambda_function.zip"
  handler = "lambda_function.lambda_handler"
  runtime = "python3.9"
}

# IAM Lambda role
resource "aws_iam_role" "iam_lambda" {
  name = "iam_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*"
}

resource "aws_iam_policy" "lambda_to_dynamodb" {
  name        = "lambda_to_dynamodb_access"
  path        = "/"
  description = "IAM policy for accessing dynamodb from a lambda function"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:UpdateItem",
                "dynamodb:GetItem"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_lambda.name
  policy_arn = aws_iam_policy.lambda_to_dynamodb.arn
}