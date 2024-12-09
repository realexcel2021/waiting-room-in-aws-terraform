# waiting room queue

resource "aws_sqs_queue" "waiting_room_queue" {
  name                    = "WaitingRoomQueue"
  kms_master_key_id       = "alias/aws/sqs"
  kms_data_key_reuse_period_seconds = 300
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.waiting_room_dead_letter_queue.arn
    maxReceiveCount     = 2
  })
  visibility_timeout_seconds = 30
}

# waiting room dlq
resource "aws_sqs_queue" "waiting_room_dead_letter_queue" {
  name                    = "WaitingRoomDeadLetterQueue"
  kms_master_key_id       = "alias/aws/sqs"
  kms_data_key_reuse_period_seconds = 300
  visibility_timeout_seconds = 30
}

resource "aws_sqs_queue_policy" "waiting_room_queue_policy" {
  queue_url = aws_sqs_queue.waiting_room_queue.id
  policy    = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowSendThroughSSLOnly"
        Effect = "Deny"
        Action = "SQS:SendMessage"
        Resource = aws_sqs_queue.waiting_room_queue.arn
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
        Principal = "*"
      }
    ]
  })
}

resource "aws_sqs_queue_policy" "waiting_room_dead_letter_queue_policy" {
  queue_url = aws_sqs_queue.waiting_room_dead_letter_queue.id
  policy    = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowSendThroughSSLOnly"
        Effect = "Deny"
        Action = "SQS:SendMessage"
        Resource = aws_sqs_queue.waiting_room_dead_letter_queue.arn
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
        Principal = "*"
      }
    ]
  })
}


resource "aws_lambda_event_source_mapping" "sqs_lambda_trigger" {
  batch_size                    = 10
  enabled                       = true
  event_source_arn              = aws_sqs_queue.waiting_room_queue.arn
  function_name                 = aws_lambda_function.assign_queue_num.arn
  maximum_batching_window_in_seconds = 0
}

