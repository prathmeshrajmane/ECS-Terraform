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
      execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"
    }

    
    resource "aws_ecs_service" "model_retrain" {
      name            = "model_retrain"                             
      cluster         = "${aws_ecs_cluster.dev1.id}"             
      task_definition = "${aws_ecs_task_definition.model_retrain-dev.arn}" 
      launch_type     = "FARGATE"
      desired_count   = 3
    
      load_balancer {
        target_group_arn = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
        container_name   = "${aws_ecs_task_definition.model_retrain-dev.family}"
        container_port   = 5001
      }
    
    }


resource "aws_alb" "application_load_balancer" {
  name               = "test-lb-tf" 
  load_balancer_type = "application"
  subnets = [ 
    "${aws_default_subnet.default_subnet_a.id}",
    "${aws_default_subnet.default_subnet_b.id}",
    "${aws_default_subnet.default_subnet_c.id}"
  ]
  security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
}

resource "aws_lb_target_group" "target_group" {
  name        = "target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "${aws_default_vpc.default_vpc.id}" 
  health_check {
    matcher = "200,301,302"
    path = "/"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = "${aws_alb.application_load_balancer.arn}" 
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.target_group.arn}" 
  }
}

resource "aws_default_vpc" "default_vpc" {
}

resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "us-east-2a"
}

resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "us-east-2b"
}

resource "aws_default_subnet" "default_subnet_c" {
  availability_zone = "us-east-2c"
}



resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_security_group" "load_balancer_security_group" {
  ingress {
    from_port   = 80 
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0 
    to_port     = 0 
    protocol    = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
  }
}

resource "aws_security_group" "service_security_group" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0 
    to_port     = 0 
    protocol    = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
  }
}
