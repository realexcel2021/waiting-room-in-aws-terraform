# assign queue number lambda
resource "aws_lambda_function" "assign_queue_num" {
  filename         = "Custom-resources/virtual-waiting-room-on-aws.zip"
  function_name    = "AssignQueueNum"
  role             = aws_iam_role.assign_queue_role.arn
  handler          = "assign_queue_num.lambda_handler"
  runtime          = "python3.12"
  memory_size      = 1024
  timeout          = 30
  #source_code_hash = filebase64sha256("${path.module}/lambda.zip")
  
  
  environment {
    variables = {
      REDIS_HOST                      = aws_elasticache_replication_group.redis_replication_group.primary_endpoint_address
      REDIS_PORT                      = var.redis_port
      QUEUE_URL                       = aws_sqs_queue.waiting_room_queue.url
      EVENT_ID                        = var.event_id
      SOLUTION_ID                     = var.solution_id
      QUEUE_POSITION_ENTRYTIME_TABLE  = aws_dynamodb_table.queue_position_entry_time_table.name
      ENABLE_QUEUE_POSITION_EXPIRY    = true
      STACK_NAME                      = var.project_name
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.redis_security_group.id]
    subnet_ids         = module.vpc.private_subnets
  }

  layers = [
    aws_lambda_layer_version.redis_layer.arn
  ]
}

resource "aws_lambda_permission" "sqs_invoke_lambda" {
  statement_id  = "AllowSQSToInvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.assign_queue_num.arn
  principal     = "sqs.amazonaws.com"

  source_arn = aws_sqs_queue.waiting_room_queue.arn
}



# generate auth token lambda
resource "aws_lambda_function" "auth_generate_token" {
  function_name    = "AuthGenerateToken"
  role             = aws_iam_role.generate_token_role.arn
  handler          = "auth_generate_token.lambda_handler"
  runtime          = "python3.12"
  memory_size      = 1024
  timeout          = 30
  filename         = "Custom-resources/virtual-waiting-room-on-aws.zip"


  environment {
    variables = {
      REDIS_HOST                      = aws_elasticache_replication_group.redis_replication_group.primary_endpoint_address
      REDIS_PORT                      = var.redis_port
      TOKEN_TABLE                     = aws_dynamodb_table.token_table.name
      STACK_NAME                      = var.project_name
      EVENT_ID                        = var.event_id
      VALIDITY_PERIOD                 = var.validity_period
      QUEUE_POSITION_ENTRYTIME_TABLE  = aws_dynamodb_table.queue_position_entry_time_table.name
      SERVING_COUNTER_ISSUEDAT_TABLE  = aws_dynamodb_table.serving_counter_issued_at_table.name
      QUEUE_POSITION_EXPIRY_PERIOD    = var.queue_position_expiry_period
      ENABLE_QUEUE_POSITION_EXPIRY    = var.enable_queue_position_expiry
      EVENT_BUS_NAME                  = aws_cloudwatch_event_bus.waiting_room_event_bus.name
      SOLUTION_ID                     = var.solution_id
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.redis_security_group.id]
    subnet_ids         = module.vpc.private_subnets
  }

  layers = [
    aws_lambda_layer_version.redis_layer.arn,
    aws_lambda_layer_version.jwcrypto_layer.arn
  ]
}

# generate auth token lambda permission

resource "aws_lambda_permission" "auth_generate_token_permission" {
  statement_id  = "AuthGenerateTokenPermission"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth_generate_token.arn
  principal     = "apigateway.amazonaws.com"
  
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.private_waiting_room_api.id}/*/POST/generate_token"
}

# get number of active tokens lambda
resource "aws_lambda_function" "get_num_active_tokens" {
  function_name    = "GetNumActiveTokens"
  role             = aws_iam_role.get_token_role.arn
  handler          = "get_num_active_tokens.lambda_handler"
  runtime          = "python3.12"
  memory_size      = 1024
  timeout          = 30
  filename         = "Custom-resources/virtual-waiting-room-on-aws.zip"  

  environment {
    variables = {
      TOKEN_TABLE      = aws_dynamodb_table.token_table.name
      EVENT_ID         = var.event_id
      SOLUTION_ID      = var.solution_id
    }
  }
}

# get number of active tokens lambda permission
resource "aws_lambda_permission" "get_num_active_tokens_permission" {
  statement_id  = "GetNumActiveTokensPermission"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_num_active_tokens.arn
  principal     = "apigateway.amazonaws.com"
  
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.private_waiting_room_api.id}/*/GET/num_active_tokens"
}

# get expired tokens lambda
resource "aws_lambda_function" "get_expired_tokens" {
  function_name    = "GetExpiredTokens"
  role             = aws_iam_role.get_token_role.arn
  handler          = "get_list_expired_tokens.lambda_handler"
  runtime          = "python3.12"
  memory_size      = 1024
  timeout          = 30
  filename         = "Custom-resources/virtual-waiting-room-on-aws.zip"


  environment {
    variables = {
      TOKEN_TABLE  = aws_dynamodb_table.token_table.name
      EVENT_ID     = var.event_id
      SOLUTION_ID  = var.solution_id
    }
  }
}

# get expired tokens lambda permission
resource "aws_lambda_permission" "get_expired_tokens_permission" {
  statement_id  = "GetExpiredTokensPermission"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_expired_tokens.arn
  principal     = "apigateway.amazonaws.com"
  
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.private_waiting_room_api.id}/*/GET/expired_tokens"
}


# get serving number lambda 
resource "aws_lambda_function" "get_serving_num" {
  function_name    = "GetServingNum"
  role             = aws_iam_role.lambda_vpc_role.arn
  handler          = "get_serving_num.lambda_handler"
  runtime          = "python3.12"
  memory_size      = 1024
  timeout          = 30
  filename         = "Custom-resources/virtual-waiting-room-on-aws.zip"


  environment {
    variables = {
      REDIS_HOST   = aws_elasticache_replication_group.redis_replication_group.primary_endpoint_address
      REDIS_PORT   = var.redis_port
      EVENT_ID     = var.event_id
      SOLUTION_ID  = var.solution_id
      STACK_NAME   = var.project_name
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.redis_security_group.id]
    subnet_ids         = module.vpc.private_subnets
  }

  layers = [
    aws_lambda_layer_version.redis_layer.arn
  ]
}

resource "aws_lambda_permission" "get_serving_num_permission" {
  statement_id  = "GetServingNumPermission"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_serving_num.arn
  principal     = "apigateway.amazonaws.com"
  
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.public_waiting_room_api.id}/*/GET/serving_num"
}


# get waiting number lambda 

resource "aws_lambda_function" "get_waiting_num" {
  function_name    = "GetWaitingNum"
  role             = aws_iam_role.lambda_vpc_role.arn
  handler          = "get_waiting_num.lambda_handler"
  runtime          = "python3.12"
  memory_size      = 1024
  timeout          = 30
  filename    = "Custom-resources/virtual-waiting-room-on-aws.zip"

  environment {
    variables = {
      REDIS_HOST   = aws_elasticache_replication_group.redis_replication_group.primary_endpoint_address
      REDIS_PORT   = var.redis_port
      EVENT_ID     = var.event_id
      SOLUTION_ID  = var.solution_id
      STACK_NAME   = var.project_name
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.redis_security_group.id]
    subnet_ids         = module.vpc.private_subnets
  }

  layers = [
    aws_lambda_layer_version.redis_layer.arn
  ]
}

resource "aws_lambda_permission" "get_waiting_num_permission" {
  statement_id  = "GetWaitingNumPermission"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_waiting_num.arn
  principal     = "apigateway.amazonaws.com"
  
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.public_waiting_room_api.id}/*/GET/waiting_num"
}

# generate events lambda
resource "aws_lambda_function" "generate_events" {
  function_name    = "GenerateEvents"
  role             = aws_iam_role.generate_events_role.arn
  handler          = "generate_events.lambda_handler"
  runtime          = "python3.12"
  memory_size      = 1024
  timeout          = 30

  filename    = "Custom-resources/virtual-waiting-room-on-aws.zip"

  environment {
    variables = {
      REDIS_HOST         = aws_elasticache_replication_group.redis_replication_group.primary_endpoint_address
      REDIS_PORT         = var.redis_port
      TOKEN_TABLE        = aws_dynamodb_table.token_table.name
      EVENT_ID           = var.event_id
      EVENT_BUS_NAME     = aws_cloudwatch_event_bus.waiting_room_event_bus.name
      ACTIVE_TOKENS_FN   = aws_lambda_function.get_num_active_tokens.arn
      SOLUTION_ID        = var.solution_id
      STACK_NAME         = var.project_name
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.redis_security_group.id]
    subnet_ids         = module.vpc.private_subnets
  }

  layers = [
    aws_lambda_layer_version.redis_layer.arn,
    aws_lambda_layer_version.jwcrypto_layer.arn
  ]
}

# set queue position expired
resource "aws_lambda_function" "set_queue_position_expired" {
  function_name    = "SetQueuePositionExpired"
  role             = aws_iam_role.queue_position_role.arn
  handler          = "set_max_queue_position_expired.lambda_handler"
  runtime          = "python3.12"
  memory_size      = 1024
  timeout          = 30

  filename    = "Custom-resources/virtual-waiting-room-on-aws.zip"

  environment {
    variables = {
      REDIS_HOST                        = aws_elasticache_replication_group.redis_replication_group.primary_endpoint_address
      REDIS_PORT                        = var.redis_port
      QUEUE_POSITION_ENTRYTIME_TABLE    = aws_dynamodb_table.queue_position_entry_time_table.name
      QUEUE_POSITION_EXPIRY_PERIOD      = var.queue_position_expiry_period
      SERVING_COUNTER_ISSUEDAT_TABLE    = aws_dynamodb_table.serving_counter_issued_at_table.name
      INCR_SVC_ON_QUEUE_POS_EXPIRY      = var.incr_svc_on_queue_position_expiry
      EVENT_ID                          = var.event_id
      EVENT_BUS_NAME                    = aws_cloudwatch_event_bus.waiting_room_event_bus.name
      SOLUTION_ID                       = var.solution_id
      STACK_NAME                        = var.project_name
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.redis_security_group.id]
    subnet_ids         = module.vpc.private_subnets
  }

  layers = [
    aws_lambda_layer_version.redis_layer.arn
  ]
}

# generate token lambda function

resource "aws_lambda_function" "generate_token" {
  function_name    = "GenerateToken"
  role             = aws_iam_role.generate_token_role.arn
  handler          = "generate_token.lambda_handler"
  runtime          = "python3.12"
  memory_size      = 1024
  timeout          = 30

  filename    = "Custom-resources/virtual-waiting-room-on-aws.zip"

  environment {
    variables = {
      REDIS_HOST                        = aws_elasticache_replication_group.redis_replication_group.primary_endpoint_address
      REDIS_PORT                        = var.redis_port
      TOKEN_TABLE                       = aws_dynamodb_table.token_table.name
      STACK_NAME                        = var.project_name
      EVENT_ID                          = var.event_id
      VALIDITY_PERIOD                   = var.validity_period
      QUEUE_POSITION_ENTRYTIME_TABLE    = aws_dynamodb_table.queue_position_entry_time_table.name
      SERVING_COUNTER_ISSUEDAT_TABLE    = aws_dynamodb_table.serving_counter_issued_at_table.name
      QUEUE_POSITION_EXPIRY_PERIOD      = var.queue_position_expiry_period
      ENABLE_QUEUE_POSITION_EXPIRY      = var.enable_queue_position_expiry
      EVENT_BUS_NAME                    = aws_cloudwatch_event_bus.waiting_room_event_bus.name
      SOLUTION_ID                       = var.solution_id
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.redis_security_group.id]
    subnet_ids         = module.vpc.private_subnets
  }

  layers = [
    aws_lambda_layer_version.redis_layer.arn,
    aws_lambda_layer_version.jwcrypto_layer.arn
  ]
}

resource "aws_lambda_permission" "generate_token_permission" {
  statement_id  = "GenerateTokenPermission"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.generate_token.arn
  principal     = "apigateway.amazonaws.com"
  
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.public_waiting_room_api.id}/*/POST/generate_token"
}

# get queue number
resource "aws_lambda_function" "get_queue_num" {
  function_name    = "GetQueueNum"
  role             = aws_iam_role.lambda_vpc_role.arn
  handler          = "get_queue_num.lambda_handler"
  runtime          = "python3.12"
  memory_size      = 1024
  timeout          = 30

  filename    = "Custom-resources/virtual-waiting-room-on-aws.zip"

  environment {
    variables = {
      REDIS_HOST                     = aws_elasticache_replication_group.redis_replication_group.primary_endpoint_address
      REDIS_PORT                     = var.redis_port
      EVENT_ID                       = var.event_id
      SOLUTION_ID                    = var.solution_id
      QUEUE_POSITION_ENTRYTIME_TABLE = aws_dynamodb_table.queue_position_entry_time_table.name
      STACK_NAME                     = var.project_name
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.redis_security_group.id]
    subnet_ids         = module.vpc.private_subnets
  }

  layers = [
    aws_lambda_layer_version.redis_layer.arn
  ]
}

resource "aws_lambda_permission" "get_queue_num_permission" {
  statement_id  = "GetQueueNumPermission"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_queue_num.arn
  principal     = "apigateway.amazonaws.com"
  
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.public_waiting_room_api.id}/*/GET/queue_num"
}

# get queue position expiry time
resource "aws_lambda_function" "get_queue_position_expiry_time" {
  function_name    = "GetQueuePositionExpiryTime"
  role             = aws_iam_role.queue_position_role.arn
  handler          = "get_queue_position_expiry_time.lambda_handler"
  runtime          = "python3.12"
  memory_size      = 1024
  timeout          = 30

  filename    = "Custom-resources/virtual-waiting-room-on-aws.zip"

  environment {
    variables = {
      REDIS_HOST                        = aws_elasticache_replication_group.redis_replication_group.primary_endpoint_address
      REDIS_PORT                        = var.redis_port
      EVENT_ID                          = var.event_id
      SOLUTION_ID                       = var.solution_id
      QUEUE_POSITION_ENTRYTIME_TABLE    = aws_dynamodb_table.queue_position_entry_time_table.name
      SERVING_COUNTER_ISSUEDAT_TABLE    = aws_dynamodb_table.serving_counter_issued_at_table.name
      QUEUE_POSITION_EXPIRY_PERIOD      = var.queue_position_expiry_period
      ENABLE_QUEUE_POSITION_EXPIRY      = var.enable_queue_position_expiry
      STACK_NAME                        = var.project_name
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.redis_security_group.id]
    subnet_ids         = module.vpc.private_subnets
  }

  layers = [
    aws_lambda_layer_version.redis_layer.arn
  ]
}

resource "aws_lambda_permission" "get_queue_position_expiry_time_permission" {
  statement_id  = "GetQueuePositionExpiryTimePermission"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_queue_position_expiry_time.arn
  principal     = "apigateway.amazonaws.com"
  
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.public_waiting_room_api.id}/*/GET/queue_pos_expiry"
}

# get public key
resource "aws_lambda_function" "get_public_key" {
  function_name    = "GetPublicKey"
  role             = aws_iam_role.secrets_manager_read_role.arn
  handler          = "get_public_key.lambda_handler"
  runtime          = "python3.12"
  memory_size      = 1024
  timeout          = 30

  filename    = "Custom-resources/virtual-waiting-room-on-aws.zip"

  environment {
    variables = {
      STACK_NAME   = var.project_name
      EVENT_ID     = var.event_id
      SOLUTION_ID  = var.solution_id
    }
  }
}

resource "aws_lambda_permission" "get_public_key_permission" {
  statement_id  = "GetPublicKeyPermission"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_public_key.arn
  principal     = "apigateway.amazonaws.com"
  
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.public_waiting_room_api.id}/*/GET/public_key"
}

# increment serving counter lambda
resource "aws_lambda_function" "increment_serving_counter" {
  function_name    = "IncrementServingCounter"
  role             = aws_iam_role.queue_position_role.arn
  handler          = "increment_serving_counter.lambda_handler"
  runtime          = "python3.12"
  memory_size      = 1024
  timeout          = 30

  filename    = "Custom-resources/virtual-waiting-room-on-aws.zip"

  environment {
    variables = {
      REDIS_HOST                    = aws_elasticache_replication_group.redis_replication_group.primary_endpoint_address
      REDIS_PORT                    = var.redis_port
      EVENT_ID                      = var.event_id
      SOLUTION_ID                   = var.solution_id
      SERVING_COUNTER_ISSUEDAT_TABLE = aws_dynamodb_table.serving_counter_issued_at_table.name
      ENABLE_QUEUE_POSITION_EXPIRY  = var.enable_queue_position_expiry
      STACK_NAME                    = var.project_name
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.redis_security_group.id]
    subnet_ids         = module.vpc.private_subnets
  }

  layers = [
    aws_lambda_layer_version.redis_layer.arn
  ]
}

resource "aws_lambda_permission" "increment_serving_counter_permission" {
  statement_id  = "IncrementServingCounterPermission"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.increment_serving_counter.arn
  principal     = "apigateway.amazonaws.com"
  
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.private_waiting_room_api.id}/*/POST/increment_serving_counter"
}

# update session
resource "aws_lambda_function" "update_session" {
  function_name    = "UpdateSession"
  role             = aws_iam_role.update_session_role.arn
  handler          = "update_session.lambda_handler"
  runtime          = "python3.12"
  memory_size      = 1024
  timeout          = 30

  filename    = "Custom-resources/virtual-waiting-room-on-aws.zip"

  environment {
    variables = {
      TOKEN_TABLE          = aws_dynamodb_table.token_table.name
      EVENT_ID             = var.event_id
      EVENT_BUS_NAME       = aws_cloudwatch_event_bus.waiting_room_event_bus.name
      REDIS_HOST           = aws_elasticache_replication_group.redis_replication_group.primary_endpoint_address
      REDIS_PORT           = var.redis_port
      SOLUTION_ID          = var.solution_id
      STACK_NAME           = var.project_name
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.redis_security_group.id]
    subnet_ids         = module.vpc.private_subnets
  }

  layers = [
    aws_lambda_layer_version.redis_layer.arn
  ]
}

resource "aws_lambda_permission" "update_session_permission" {
  statement_id  = "UpdateSessionPermission"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_session.arn
  principal     = "apigateway.amazonaws.com"
  
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.private_waiting_room_api.id}/*/POST/update_session"
}

# reset state lambda
resource "aws_lambda_function" "reset_state" {
  function_name    = "ResetState"
  role             = aws_iam_role.get_token_role.arn
  handler          = "reset_initial_state.lambda_handler"
  runtime          = "python3.12"
  memory_size      = 1024
  timeout          = 300

  filename    = "Custom-resources/virtual-waiting-room-on-aws.zip"

  environment {
    variables = {
      TOKEN_TABLE                   = aws_dynamodb_table.token_table.name
      QUEUE_POSITION_ENTRYTIME_TABLE = aws_dynamodb_table.queue_position_entry_time_table.name
      SERVING_COUNTER_ISSUEDAT_TABLE = aws_dynamodb_table.serving_counter_issued_at_table.name
      EVENT_ID                      = var.event_id
      REDIS_HOST                    = aws_elasticache_replication_group.redis_replication_group.primary_endpoint_address
      REDIS_PORT                    = var.redis_port
      SOLUTION_ID                   = var.solution_id
      STACK_NAME                    = var.project_name
      CLOUDFRONT_DISTRIBUTION_ID    = aws_cloudfront_distribution.public_api_cloudfront.id
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.redis_security_group.id]
    subnet_ids         = module.vpc.private_subnets
  }

  layers = [
    aws_lambda_layer_version.redis_layer.arn
  ]
}

resource "aws_lambda_permission" "reset_state_permission" {
  statement_id  = "ResetStatePermission"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.reset_state.arn
  principal     = "apigateway.amazonaws.com"
  
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.private_waiting_room_api.id}/*/POST/reset_initial_state"
}

# generate keys lambda

resource "aws_lambda_function" "generate_keys" {
  function_name    = "GenerateKeys"
  role             = aws_iam_role.generate_keys_role.arn
  handler          = "generate_keys.handler"
  runtime          = "python3.12"
  memory_size      = 1024
  timeout          = 30

  filename    = "Custom-resources/virtual-waiting-room-on-aws-custom-resources.zip"

  environment {
    variables = {
      STACK_NAME  = var.project_name
      SOLUTION_ID = var.solution_id
    }
  }

  layers = [
    aws_lambda_layer_version.jwcrypto_layer.arn
  ]
}

# initialize state

resource "aws_lambda_function" "initialize_state" {
  function_name    = "InitializeState"
  role             = aws_iam_role.initialize_state_role.arn
  handler          = "initialize_state.handler"
  runtime          = "python3.12"
  memory_size      = 1024
  timeout          = 30
  depends_on       = [
    aws_dynamodb_table.token_table,
    aws_elasticache_replication_group.redis_replication_group,
    aws_dynamodb_table.queue_position_entry_time_table,
    aws_dynamodb_table.serving_counter_issued_at_table
  ]

  filename    = "Custom-resources/virtual-waiting-room-on-aws-custom-resources.zip"

  environment {
    variables = {
      EVENT_ID             = var.event_id
      CORE_API_ENDPOINT    = "https://${aws_api_gateway_rest_api.private_waiting_room_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/dev"
      PRIVATE_API_ID       = aws_api_gateway_rest_api.private_waiting_room_api.id
      PUBLIC_API_ID        = aws_api_gateway_rest_api.public_waiting_room_api.id
      SOLUTION_ID          = var.solution_id
      API_STAGE            = "dev"
    }
  }
}
