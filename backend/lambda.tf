# Creates Lambda functions
resource "aws_lambda_function" "counter_function" {
  function_name    = "counter_function"
  filename         = "lambda/counter_function.zip"
  role             = aws_iam_role.exec_role.arn 
  handler          = "counter_function.lambda_handler"
  source_code_hash = filebase64sha256("lambda/counter_function.zip")
  timeout          = "30"

  runtime          = "python3.9"
}

# IAM role for Lambda
resource "aws_iam_role" "exec_role" {
  name = "counter_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

# IAM policy for Lambda-DynamoDB access
resource "aws_iam_policy" "db_policy" {
  name        = "counter_db_policy"
  description = "policy that allows POST and GET"
  path        = "/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:UpdateItem"
        ]
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attatches GET DynamoDB policy to Lambda role
resource "aws_iam_role_policy_attachment" "attatch_get_policy" {
  role       = aws_iam_role.exec_role.name
  policy_arn = aws_iam_policy.db_policy.arn
}

# Allows API to access GET lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction" 
  function_name = aws_lambda_function.counter_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.counter_api.execution_arn}/*"
}


