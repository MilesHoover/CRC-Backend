# Creates PUT function
resource "aws_lambda_function" "put" {
  function_name = "put_function"
  filename      = "lambda/put_function/put_function.zip"
  role          = aws_iam_role.put_role.arn
  runtime       = "python3.9"
  handler       = put_function.put_handler
}

# IAM role for PUT Lambda
resource "aws_iam_role" "put_role" {
  name = "iam_put"
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

# IAM policy for PUT Lambda-DynamoDB access
resource "aws_iam_policy" "put_policy" {
  name        = "allow_put"
  description = "policy that allows PUT"
  path        = "/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:UpdateItem"
        ]
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attatches PUT DynamoDB policy to Lambda role
resource "aws_iam_role_policy_attachment" "attach_put_policy" {
  role       = aws_iam_role.put_role.name
  policy_arn = aws_iam_policy.put_policy.arn
}

# Allows API to access PUT lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowCounterAPIInvoke"
  action        = "lambda:InvokeFunction" 
  function_name = aws_lambda_function.put.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.page_count.execution_arn}/*"
}



