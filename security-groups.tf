resource "aws_security_group" "redis_security_group" {
  name        = "RedisSecurityGroup"
  description = "Allows Lambda to connect to Redis"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Ingress rule for first subnet."
    from_port   = var.redis_port
    to_port     = var.redis_port
    protocol    = "tcp"
    cidr_blocks = ["10.0.16.0/20"]
  }

  ingress {
    description = "Ingress rule for second subnet."
    from_port   = var.redis_port
    to_port     = var.redis_port
    protocol    = "tcp"
    cidr_blocks = ["10.0.32.0/20"]
  }

  egress {
    description = "Egress rule for Redis security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "redis_security_group"
  }
}
