resource "aws_elasticache_replication_group" "redis_replication_group" {
  depends_on                = [aws_secretsmanager_secret.redis_auth]
  description               = "Waiting room elasticache cluster" 
  replication_group_id      = "${var.project_name}-redis-replication-group"
  at_rest_encryption_enabled    = true
  auth_token                   = data.aws_secretsmanager_secret_version.redis_auth.secret_string
  automatic_failover_enabled    = true
  node_type                     = "cache.r6g.large"
   
  subnet_group_name             = aws_elasticache_subnet_group.SubnetGroup.id
  engine                        = "redis"
  multi_az_enabled              = true
  num_node_groups               = 1
  port                          = var.redis_port
  replicas_per_node_group       = 1
  security_group_ids            = [aws_security_group.redis_security_group.id]
  transit_encryption_enabled    = true
}



