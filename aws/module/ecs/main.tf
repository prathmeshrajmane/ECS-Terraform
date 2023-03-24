resource "aws_ecs_cluster" "dev" {
name = "dev"
}
resource "aws_ecs_task_definition" "my_first_task" {
  family                   = "my-first-task" 
  container_definitions    = <<DEFINITION
  [
    {
      "name": "my-first-task",
      "image": "${aws_ecr_repository.object-detection.repository_url}",
      "essential": true,
      "environment": [
                {
                    "name": "CELERY_BROKER_URL",
                    "value": "amqps://guest:guest@b-7f5a7363-a09a-4961-ad0a-07bb6bd8945a.mq.ap-south-1.amazonaws.com:5671"
                },
                {
                    "name": "CELERY_RESULT_BACKEND",
                    "value": "mongodb://prod:admin123@172.31.33.136:27017/?retryWrites=true&w=majority"
                }
            ],
      "portMappings": [
        {
          "containerPort": 5006,
          "hostPort": 5006
        }
      ],
      "memory": 4096,
      "cpu": 2048
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] 
  network_mode             = "awsvpc"    
  memory                   = 4096       
  cpu                      = 2048       
  execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"
}

resource "aws_ecs_service" "my_first_service" {
  name            = "my-first-service"                             
  cluster         = "${aws_ecs_cluster.my_cluster.id}"             
  task_definition = "${aws_ecs_task_definition.my_first_task.arn}" 
  launch_type     = "FARGATE"
  desired_count   = 1

  load_balancer {
    target_group_arn = "${aws_lb_target_group.target_group.arn}" 
    container_name   = "${aws_ecs_task_definition.my_first_task.family}"
    container_port   = 5006
  }

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
    assign_public_ip = true 
    security_groups  = ["${aws_security_group.service_security_group.id}"]

  }
}
