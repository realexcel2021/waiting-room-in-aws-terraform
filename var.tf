variable "region" {
  type = string
  default = "us-east-1"
}

variable "redis_port" {
  description = "Port for Redis service"
  default     = 6379  # Replace this with your actual Redis port if different
}

variable "project_name" {
  description = "Name of the AWS project"
  default     = "aws-waiting-room-demo" 
}

variable "event_id" {
  type = string
  default = "sampleevent"
}

variable "solution_id" {
  type = string
  default = "sol1id"
}

variable "validity_period" {
  type = number
  default = 3600
}

variable "queue_position_expiry_period" {
  type = number
  default = 900
}

variable "enable_queue_position_expiry" {
  type = bool
  default = true
}

variable "incr_svc_on_queue_position_expiry" {
  description = "Increment service on queue position expiry"
  type        = bool
  default = false 
}