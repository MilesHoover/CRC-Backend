# DynamoDB table for page counter web app
resource "aws_dynamodb_table" "count_db"{
  name         = "count_db"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "PK"

  attribute {
    name = "PK"
    type = "N"
  }
}