data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "WaitingRoomVpc"
  cidr = "10.0.0.0/16"

  azs             = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1], data.aws_availability_zones.available.names[2]]
  private_subnets = ["10.0.32.0/20", "10.0.16.0/20"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Project = "AWSWaitingRoom"
    Environment = "dev"
  }
}

resource "aws_elasticache_subnet_group" "SubnetGroup" {
  name       = "WaitingRoomSubnetGroup"
  subnet_ids = module.vpc.private_subnets
}

###########################
# vpc endpoints

# sqs endpoint
resource "aws_vpc_endpoint" "sqs_endpoint" {
  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.${data.aws_region.current.name}.sqs"
  vpc_endpoint_type  = "Interface"
  private_dns_enabled = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sqs:SendMessage",
          "sqs:DeleteMessage",
          "sqs:ReceiveMessage"
        ]
        Effect = "Allow"
        Resource = aws_sqs_queue.waiting_room_queue.arn
        Principal = {
          AWS = "*"
        }
      }
    ]
  })

  security_group_ids = [
    module.vpc.default_security_group_id
  ]

  subnet_ids = module.vpc.private_subnets
}

# dynamodb endpoint

resource "aws_vpc_endpoint" "dynamodb_endpoint" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  vpc_endpoint_type = "Gateway"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:Query",
          "dynamodb:UpdateItem",
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateContinuousBackups",
          "dynamodb:CreateTable",
          "dynamodb:DeleteTable",
          "dynamodb:DescribeTable"
        ]
        Effect = "Allow"
        Resource = [
          aws_dynamodb_table.token_table.arn,
          "${aws_dynamodb_table.token_table.arn}/index/*",
          aws_dynamodb_table.queue_position_entry_time_table.arn,
          "${aws_dynamodb_table.queue_position_entry_time_table.arn}/index/*",
          aws_dynamodb_table.serving_counter_issued_at_table.arn,
          "${aws_dynamodb_table.serving_counter_issued_at_table.arn}/index/*"
        ]
        Principal = {
          AWS = "*"
        }
      }
    ]
  })

  route_table_ids = module.vpc.private_route_table_ids

}

# secrets manager endpoint

resource "aws_vpc_endpoint" "secrets_manager_endpoint" {
  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_endpoint_type  = "Interface"
  private_dns_enabled = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:CreateSecret",
          "secretsmanager:UpdateSecret",
          "secretsmanager:DeleteSecret",
          "secretsmanager:PutSecretValue"
        ]
        Effect = "Allow"
        Resource = "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${var.project_name}*"
        Principal = {
          AWS = "*"
        }
      }
    ]
  })

  security_group_ids = [
    module.vpc.default_security_group_id
  ]

  subnet_ids = module.vpc.private_subnets
}

# events endpoint

resource "aws_vpc_endpoint" "events_endpoint" {
  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.${data.aws_region.current.name}.events"
  vpc_endpoint_type  = "Interface"
  private_dns_enabled = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "events:PutEvents"
        ]
        Effect = "Allow"
        Resource = aws_cloudwatch_event_bus.waiting_room_event_bus.arn
        Principal = {
          AWS = "*"
        }
      }
    ]
  })

  security_group_ids = [
    module.vpc.default_security_group_id
  ]

  subnet_ids = module.vpc.private_subnets
}


# Lambda endpoint 

resource "aws_vpc_endpoint" "lambda_endpoint" {
  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.${data.aws_region.current.name}.lambda"
  vpc_endpoint_type  = "Interface"
  private_dns_enabled = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction"
        ]
        Effect = "Allow"
        Resource = aws_lambda_function.get_num_active_tokens.arn
        Principal = {
          AWS = "*"
        }
      }
    ]
  })

  security_group_ids = [
    module.vpc.default_security_group_id
  ]

  subnet_ids = module.vpc.private_subnets
}

