resource "aws_ecs_cluster" "dev1" {
    name = "dev1"
}


resource "aws_ecs_task_definition" "model_retrain-dev" {
      family                   = "model_retrain-dev" 
      container_definitions    = <<DEFINITION
      [
        {
          "name": "model_retrain-dev",
          "image": "docker.io/prathmeshrajmane/webapp:2",
          "portMappings": [
            {
              "containerPort": 5001,
              "hostPort": 5001
            }
          ],
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
          "memory": 2048,
          "cpu": 1024
        }
      ]
      DEFINITION
      requires_compatibilities = ["FARGATE"] 
      network_mode             = "awsvpc"   
      memory                   = 2048     
      cpu                      = 1024       
      execution_role_arn       = var.aws_role_arn
    }

    
    resource "aws_ecs_service" "model_retrain" {
      name            = "model_retrain"                             
      cluster         = "${aws_ecs_cluster.my_cluster.id}"             
      task_definition = "${aws_ecs_task_definition.model_retrain-dev.arn}" 
      launch_type     = "FARGATE"
      desired_count   = 3
    
      load_balancer {
        target_group_arn = var.alb_arn 
        container_name   = "${aws_ecs_task_definition.model_retrain-dev.family}"
        container_port   = 5001
      }
    
    }
