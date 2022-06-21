# REST API
resource "aws_api_gateway_rest_api" "counter_api" {
    name        = "counter_api"
    description = "This is the API that will handle my page view count webapp"
}

# API Gateway resource
resource "aws_api_gateway_resource" "counter_resource" {
    rest_api_id = aws_api_gateway_rest_api.counter_api.id
    parent_id   = aws_api_gateway_rest_api.counter_api.root_resource_id
    path_part   = "count"
}

# API method
resource "aws_api_gateway_method" "counter_method" {
    rest_api_id   = aws_api_gateway_rest_api.counter_api.id
    resource_id   = aws_api_gateway_resource.counter_resource.id
    http_method   = "GET"
    authorization = "NONE"
}

# API integration
resource "aws_api_gateway_integration" "counter_integration" {
    rest_api_id             = aws_api_gateway_rest_api.counter_api.id
    resource_id             = aws_api_gateway_resource.counter_resource.id
    http_method             = aws_api_gateway_method.counter_method.http_method
    integration_http_method = "POST"
    type                    = "AWS"
    uri                     = aws_lambda_function.counter_function.invoke_arn
    content_handling        = "CONVERT_TO_TEXT"
}

# API method response
resource "aws_api_gateway_method_response" "counter_method_response" {
    rest_api_id = aws_api_gateway_rest_api.counter_api.id
    resource_id = aws_api_gateway_resource.counter_resource.id
    http_method = aws_api_gateway_method.counter_method.http_method
    status_code = "200"
    response_models = {
        "application/json" = "Empty"
    }
    response_parameters = {
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Headers" = true,
        "method.response.header.Access-Control-Allow-Origin" = true
    }
}

# API integration response
resource "aws_api_gateway_integration_response" "counter_integration_response" {
    rest_api_id = aws_api_gateway_rest_api.counter_api.id
    resource_id = aws_api_gateway_resource.counter_resource.id
    http_method = aws_api_gateway_method.counter_method.http_method
    status_code = aws_api_gateway_method_response.counter_method_response.status_code
    response_parameters = {
        "method.response.header.Access-Control-Allow-Methods" = "'GET, POST'",
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'",
        "method.response.header.Access-Control-Allow-Origin" = "'*'"
    }
    depends_on = [
        aws_api_gateway_integration.counter_integration    
    ]
        
}

# API deployment
resource "aws_api_gateway_deployment" "counter_deployment" {
    rest_api_id = aws_api_gateway_rest_api.counter_api.id

    triggers = {
        redeployment = sha1(jsonencode([
            aws_api_gateway_resource.counter_resource.id,
            aws_api_gateway_method.counter_method.id,
            aws_api_gateway_integration.counter_integration.id
        ]))
    }

    lifecycle {
        create_before_destroy = true
    }
}

# API stage
resource "aws_api_gateway_stage" "counter_stage" {
    rest_api_id   = aws_api_gateway_rest_api.counter_api.id
    deployment_id = aws_api_gateway_deployment.counter_deployment.id
    stage_name    = "prod"
}