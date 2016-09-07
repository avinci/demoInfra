# ECS clusters
resource "aws_ecs_cluster" "test-aws" {
  name = "test-aws"
}

resource "aws_ecs_cluster" "prod-aws" {
  name = "prod-aws"
}
