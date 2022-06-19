# Creates GET function
resource "aws_lambda_function" "get" {
  function_name = "get_function"
  filename      = "lambda/get_function/get_function.zip"
  role          = aws_iam_role.get_role.arn
  runtime       = "python3.9"
  handler       = get_function.get_handler
}

# IAM role for GET Lambda
resource "aws_iam_role" "get_role" {
  name = "iam_get"
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

# IAM policy for GET Lambda-DynamoDB access
resource "aws_iam_policy" "get_policy" {
  name        = "allow_get"
  description = "policy that allows GET"
  path        = "/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem"
        ]
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attatches GET DynamoDB policy to Lambda role
resource "aws_iam_role_policy_attachment" "attatch_get_policy" {
  role       = aws_iam_role.get_role.name
  policy_arn = aws_iam_policy.get_policy.arn
}

# Allows API to access GET lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowCounterAPIInvoke"
  action        = "lambda:InvokeFunction" 
  function_name = aws_lambda_function.get.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.page_count.execution_arn}/*"
}


