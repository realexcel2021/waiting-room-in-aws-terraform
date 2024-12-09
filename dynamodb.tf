resource "aws_dynamodb_table" "token_table" {
  billing_mode         = "PAY_PER_REQUEST"
  hash_key             = "request_id"
  name                 = "token_table"

  attribute {
    name = "request_id"
    type = "S"
  }

  attribute {
    name = "expires"
    type = "N"
  }

  attribute {
    name = "event_id"
    type = "S"
  }

  global_secondary_index {
    name            = "EventExpiresIndex"
    hash_key        = "event_id"
    range_key       = "expires"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }
}


resource "aws_dynamodb_table" "queue_position_entry_time_table" {
  billing_mode         = "PAY_PER_REQUEST"
  hash_key             = "request_id"
  name                 = "queue_position_entry_time_table" 

  attribute {
    name = "queue_position"
    type = "N"
  }

  attribute {
    name = "request_id"
    type = "S"
  }

  global_secondary_index {
    name            = "QueuePositionIndex"
    hash_key        = "queue_position"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }
}


resource "aws_dynamodb_table" "serving_counter_issued_at_table" {
  billing_mode         = "PAY_PER_REQUEST"
  hash_key             = "event_id"
  range_key            = "serving_counter"
  name                 = "serving_counter_issued_at_table" 

  attribute {
    name = "event_id"
    type = "S"
  }

  attribute {
    name = "serving_counter"
    type = "N"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }
}
