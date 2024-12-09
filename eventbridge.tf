resource "aws_cloudwatch_event_bus" "waiting_room_event_bus" {
  name = "${var.project_name}-WaitingRoomEventBus"
}


# metrics event rule
resource "aws_cloudwatch_event_rule" "metrics_event_rule" {
  description         = "Writes metrics related to waiting room."
  schedule_expression = "rate(1 minute)"
  state               = "ENABLED"
}


resource "aws_cloudwatch_event_target" "metrics_event_rule" {
  rule      = aws_cloudwatch_event_rule.metrics_event_rule.name
  arn       = aws_lambda_function.generate_events.arn
  target_id = "${var.project_name}-WaitingRoomEvents"
  
}

# set queue position

resource "aws_cloudwatch_event_rule" "queue_position_expired_event_rule" {
  description         = "Marks items expired in the QueuePositionEntryTimeTable."
  schedule_expression = "rate(1 minute)"
  state               = "ENABLED"
}

resource "aws_cloudwatch_event_target" "queue_position_expired_event_rule" {
  rule      = aws_cloudwatch_event_rule.queue_position_expired_event_rule.name
  arn       = aws_lambda_function.set_queue_position_expired.arn
  target_id = "${var.project_name}-expiredEvents"
}

##############################
# lambda permissions

resource "aws_lambda_permission" "generate_events_rule_permissions" {
  statement_id  = "GenerateEventsRulePermissions"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.generate_events.arn
  principal     = "events.amazonaws.com"
  
  source_arn = aws_cloudwatch_event_rule.metrics_event_rule.arn
}

resource "aws_lambda_permission" "queue_position_expired_event_rule_permissions" {
  statement_id  = "QueuePositionExpiredEventRulePermissions"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.set_queue_position_expired.arn
  principal     = "events.amazonaws.com"
  
  source_arn = aws_cloudwatch_event_rule.queue_position_expired_event_rule.arn
}
