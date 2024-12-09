# Public waiting room API

data "template_file" "public" {
  template = file("./Apigateway-Swagger/virtual-waiting-room-on-aws-swagger-public-api.json")

  vars = {
    APIStageName = "dev"
    Region       = var.region
    AccountId    = data.aws_caller_identity.current.account_id
    
    WaitingRoomQueueQueue  = "${aws_sqs_queue.waiting_room_queue.name}"
    PublicApiGwRole        = aws_iam_role.public_api_gw_role.arn

    GetPublicKeyLambdaArn = aws_lambda_function.get_public_key.arn
    GetQueueNumLambdaArn  = aws_lambda_function.get_queue_num.arn

    GetQueuePositionExpiryTimeLambdaArn = aws_lambda_function.get_queue_position_expiry_time.arn

    GetServingNumLambdaArn = aws_lambda_function.get_serving_num.arn
    GetWaitingNumLambdaArn = aws_lambda_function.get_waiting_num.arn
    GenerateTokenLambdaArn = aws_lambda_function.generate_token.arn
  }
}

resource "aws_api_gateway_rest_api" "public_waiting_room_api" {
  name        = "PublicWaitingRoomApi"
  body        = data.template_file.public.rendered
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "public_waiting_room_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.public_waiting_room_api.id
  stage_name  = "dev"

  description = "Default stage deployment for SWR API"
}


# Private waiting room API

data "template_file" "private" {
  template = file("./Apigateway-Swagger/virtual-waiting-room-on-aws-swagger-public-api.json")

  vars = {
   APIStageName = "dev"
   Region = var.region

   AuthGenerateTokenLambdaArn = aws_lambda_function.auth_generate_token.arn
   UpdateSessionLambdaArn     = aws_lambda_function.update_session.arn
   GetExpiredTokensLambdaArn  = aws_lambda_function.get_expired_tokens.arn
   IncrementServingCounterLambdaArn = aws_lambda_function.increment_serving_counter.arn
   GetNumActiveTokensLambdaArn = aws_lambda_function.get_num_active_tokens.arn
   ResetStateLambdaArn = aws_lambda_function.reset_state.arn
  }
}


resource "aws_api_gateway_rest_api" "private_waiting_room_api" {
  name        = "PrivateWaitingRoomApi"
  body        = data.template_file.private.rendered
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "private_waiting_room_api" {
  rest_api_id = aws_api_gateway_rest_api.private_waiting_room_api.id
  stage_name  = "dev"

  description = "Default stage deployment for SWR API"
}


#############################################
# API keys

resource "aws_api_gateway_api_key" "api_key" {
  description = "Public Waiting Room API Key"
  enabled     = true
  name        = "waiting-room-api-key" 

  depends_on = [aws_api_gateway_deployment.public_waiting_room_api_deployment]
}

resource "aws_api_gateway_usage_plan" "usage_plan" {
  description = "Public API key usage plan"
  name        = "waiting-room-usage-plan" 

  api_stages {
    api_id = aws_api_gateway_rest_api.public_waiting_room_api.id
    stage  = "dev"
  }

  depends_on = [aws_api_gateway_deployment.public_waiting_room_api_deployment]
}

resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  key_id      = aws_api_gateway_api_key.api_key.id
  key_type    = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan.id
}
