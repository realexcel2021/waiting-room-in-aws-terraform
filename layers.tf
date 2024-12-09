resource "aws_lambda_layer_version" "redis_layer" {
  compatible_runtimes = ["python3.12"]
  description         = "Redis Layer"
  layer_name          = "${var.project_name}-RedisLayer"

  filename            = "layers/virtual-waiting-room-on-aws-redis-layer.zip" 
}

resource "aws_lambda_layer_version" "jwcrypto_layer" {
  compatible_runtimes = ["python3.12"]
  description         = "Jwcrypto Layer"
  layer_name          = "${var.project_name}-JwcryptoLayer"
  license_info        = "MIT"
  filename            = "layers/virtual-waiting-room-on-aws-jwcrypto-layer.zip" 
}




