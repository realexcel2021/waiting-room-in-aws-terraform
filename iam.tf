## Public API gateway iam role

resource "aws_iam_role" "public_api_gw_role" {
  name = "PublicApiGwRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "PublicApiGwRolePolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid = "PublicApiGwRole"
          Effect = "Allow"
          Action = [
            "sqs:SendMessage"
          ]
          Resource = "${aws_sqs_queue.waiting_room_queue.arn}"
        },
        {
          Effect = "Allow"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
            "logs:PutLogEvents",
            "logs:GetLogEvents",
            "logs:FilterLogEvents"
          ]
          Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*:*"
        }
      ]
    })
  }
}


## Private api gateway role

resource "aws_iam_role" "private_api_gw_role" {
  name = "PrivateApiGwRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "PrivateApiGwRolePolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
            "logs:PutLogEvents",
            "logs:GetLogEvents",
            "logs:FilterLogEvents"
          ]
          Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*:*"
        }
      ]
    })
  }
}


## Assign queue lambda role

resource "aws_iam_role" "assign_queue_role" {
  name = "AssignQueueRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "AssignQueuePolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "sqs:SendMessage",
            "sqs:ReceiveMessage",
            "sqs:*",
            "dynamodb:*",
            "ec2:DescribeNetworkInterfaces",
            "ec2:CreateNetworkInterface",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeInstances",
            "ec2:DetachNetworkInterface"
          ]
          Resource = "*"
        }
      ]
    })
  }
}

# generate token lambda role
resource "aws_iam_role" "generate_token_role" {
  name = "GenerateTokenRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "GenerateTokenPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "sqs:SendMessage",
            "sqs:ReceiveMessage",
            "dynamodb:*",
            "secretsmanager:GetSecretValue",
            "ec2:DescribeNetworkInterfaces",
            "ec2:CreateNetworkInterface",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeInstances",
            "ec2:DetachNetworkInterface",
            "events:PutEvents"
          ]
          Resource = "*"
        }
      ]
    })
  }
}

# get token lambda role
resource "aws_iam_role" "get_token_role" {
  name = "GetTokenRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "GetTokenPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "dynamodb:*",
            "secretsmanager:GetSecretValue",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "*"
        }
      ]
    })
  }
}

# get serving number lambda role
resource "aws_iam_role" "lambda_vpc_role" {
  name = "LambdaVpcRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "LambdaVpcPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "ec2:DescribeNetworkInterfaces",
            "ec2:CreateNetworkInterface",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeInstances",
            "ec2:DetachNetworkInterface",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "*"
        }
      ]
    })
  }
}


# generate events lambda role

resource "aws_iam_role" "generate_events_role" {
  name = "GenerateEventsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "GenerateEventsPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "dynamodb:*",
            "secretsmanager:GetSecretValue",
            "ec2:DescribeNetworkInterfaces",
            "ec2:CreateNetworkInterface",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeInstances",
            "ec2:DetachNetworkInterface",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "events:PutEvents"
          ]
          Resource = "*"
        }
      ]
    })
  }
}


# queue position role
resource "aws_iam_role" "queue_position_role" {
  name = "QueuePositionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "QueuePositionPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "dynamodb:*",
            "secretsmanager:GetSecretValue",
            "ec2:DescribeNetworkInterfaces",
            "ec2:CreateNetworkInterface",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeInstances",
            "ec2:DetachNetworkInterface",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "events:PutEvents"
          ]
          Resource = "*"
        }
      ]
    })
  }
}

# get public key
resource "aws_iam_role" "secrets_manager_read_role" {
  name = "SecretsManagerReadRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "SecretsManagerReadPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "secretsmanager:GetSecretValue",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "*"
        }
      ]
    })
  }
}

# update session role
resource "aws_iam_role" "update_session_role" {
  name = "UpdateSessionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "UpdateSessionPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "dynamodb:*",
            "secretsmanager:GetSecretValue",
            "ec2:DescribeNetworkInterfaces",
            "ec2:CreateNetworkInterface",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeInstances",
            "ec2:DetachNetworkInterface",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "events:PutEvents"
          ]
          Resource = "*"
        }
      ]
    })
  }
}

resource "aws_iam_role" "generate_keys_role" {
  name               = "GenerateKeysRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "GenerateKeysRolePolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:CreateSecret",
            "secretsmanager:UpdateSecret",
            "secretsmanager:DeleteSecret",
            "secretsmanager:PutSecretValue"
          ]
          Resource = "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${var.project_name}*"
        },
        {
          Effect = "Allow"
          Action = "secretsmanager:GetRandomPassword"
          Resource = "*"
        }
      ]
    })
  }
}



########################################################################
# policies

resource "aws_iam_policy" "cfn_invalidation_policy" {
  name   = "CfnInvalidationPolicy"
  path   = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "CfnInvalidationPolicy"
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation"
        ]
        Resource = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.public_api_cloudfront.id}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_cfn_invalidation_policy" {
  role       = aws_iam_role.get_token_role.name
  policy_arn = aws_iam_policy.cfn_invalidation_policy.arn
}

# event bridge policy
resource "aws_iam_policy" "events_policy" {
  name   = "EventsPolicy"
  path   = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "events:PutEvents"
        ]
        Resource = aws_cloudwatch_event_bus.waiting_room_event_bus.arn
        Sid = "EventsPolicy"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_generate_events_role" {
  role       = aws_iam_role.generate_events_role.name
  policy_arn = aws_iam_policy.events_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_update_session_role" {
  role       = aws_iam_role.update_session_role.name
  policy_arn = aws_iam_policy.events_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_generate_token_role" {
  role       = aws_iam_role.generate_token_role.name
  policy_arn = aws_iam_policy.events_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_queue_position_role" {
  role       = aws_iam_role.queue_position_role.name
  policy_arn = aws_iam_policy.events_policy.arn
}



resource "aws_iam_policy" "protected_api_policy" {
  name   = "ProtectedAPIPolicy"
  path   = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "execute-api:Invoke"
        ]
        Resource = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.private_waiting_room_api.id}/*"
      }
    ]
  })
}

resource "aws_iam_group" "protected_api_group" {
  name = "ProtectedApiGroup"
}

resource "aws_iam_group_policy_attachment" "attach_protected_api_policy" {
  group      = aws_iam_group.protected_api_group.name
  policy_arn = aws_iam_policy.protected_api_policy.arn
}


# initialize state role

resource "aws_iam_role" "initialize_state_role" {
  name = "InitializeStateRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "ApiInvokePolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "execute-api:Invoke"
          ]
          Resource = "arn:aws:execute-api:*:*:*/*/POST/reset_initial_state"
        },
        {
          Effect = "Allow"
          Action = "apigateway:POST"
          Resource = [
            "arn:aws:apigateway:${data.aws_region.current.name}::/restapis/${aws_api_gateway_rest_api.public_waiting_room_api.id}/deployments",
            "arn:aws:apigateway:${data.aws_region.current.name}::/restapis/${aws_api_gateway_rest_api.private_waiting_room_api.id}/deployments"
          ]
        }
      ]
    })
  }
}
