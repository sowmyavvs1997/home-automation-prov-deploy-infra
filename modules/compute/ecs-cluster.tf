#############################################################################
# ECS Cluster
#############################################################################

resource "aws_ecs_cluster" "this" {
  name = var.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "disabled" # keep disabled for free-tier
  }

  tags = {
    Name        = var.ecs_cluster_name
    Project     = var.project_name
    Environment = var.environment
  }
}
