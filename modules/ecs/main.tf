resource "aws_iam_service_linked_role" "service_role" {
  aws_service_name = "ecs.amazonaws.com"
}

resource "aws_ecs_cluster" "default" {
  name = var.cluster_name
}
