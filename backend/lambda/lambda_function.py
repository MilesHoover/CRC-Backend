from ast import Expression
import boto3

table_name = "count_db"
dynamodb = boto3.resource("dynamodb")
client = boto3.client('dynamodb')
table = dynamodb.Table(table_name)


def increment_visitor():
    response = client.update_item(
        TableName=table_name,
        Key = {
            'PK': {
                'N': "0"
            }
        },
        ExpressionAttributeValues = { "inc": {"N": "1"}},
        UpdateExpression = "ADD visitor :inc"
    )

def retrieve_visitor_count():
    item = table.get_item(
        Key = {
            "PK": 0
        }
    )
    visitcount = (item["Item"])["visitor"]
    return visitcount

def lambda_handler(event, context):
    increment_visitor()
    return retrieve_visitor_count()