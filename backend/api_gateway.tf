# API Gateway REST API
resource "aws_api_gateway_rest_api" "page_count" {
    name        = "page_count"
    description = "This is the API that will handle my page view count webapp"
}

# API Gateway resource
resource "aws_api_gateway_resource" "resource" {
    rest_api_id = aws_api_gateway_rest_api.page_count.id
    parent_id   = aws_api_gateway_rest_api.page_count.root_resource_id
    path_part   = "pagecount"
}

# API method
resource "aws_api_gateway_method" "method" {

}