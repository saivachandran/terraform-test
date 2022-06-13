
# app

data "template_file" "myapp-task-definition-template" {
  template = file("templates/app.json.tpl")
  vars = {
    REPOSITORY_URL = replace(aws_ecr_repository.myapp.repository_url, "https://", "")
  }
}

resource "aws_ecs_task_definition" "myapp-task-definition" {
  family                = "myapp"
  container_definitions = data.template_file.myapp-task-definition-template.rendered
}

resource "aws_elb" "myapp-elb" {
  name = "myapp-elb"

  listener {
    instance_port     = 3000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 30
    target              = "HTTP:3000/"
    interval            = 60
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  subnets         = [aws_subnet.main-public-1.id, aws_subnet.main-public-2.id]
  security_groups = [aws_security_group.myapp-elb-securitygroup.id]

  tags = {
    Name = "myapp-elb"
  }
}

resource "aws_ecs_service" "myapp-service" {
  name            = "myapp"
  cluster         = aws_ecs_cluster.example-cluster.id
  task_definition = aws_ecs_task_definition.myapp-task-definition.arn
  desired_count   = 3
  iam_role        = aws_iam_role.ecs-service-role.arn
  depends_on      = [aws_iam_policy_attachment.ecs-service-attach1]
  force_new_deployment               = true
  load_balancer {
    elb_name       = aws_elb.myapp-elb.name
    container_name = "myapp"
    container_port = 3000

  }

  lifecycle {
    ignore_changes = [
      capacity_provider_strategy
    ]
  }
  capacity_provider_strategy {
    base              =  2
    weight            =  0
    capacity_provider = aws_ecs_capacity_provider.example-cluster-1.name
  }

  capacity_provider_strategy {
    base              =  0
    weight            =  1
    capacity_provider = aws_ecs_capacity_provider.example-cluster-2.name
  }
 
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 3 
  resource_id        = "service/${aws_ecs_cluster.example-cluster.name}/${aws_ecs_service.myapp-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}


resource "aws_appautoscaling_policy" "ecs_target" {
  name               = "application-scaling-policy-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 50
  }
  depends_on = [aws_appautoscaling_target.ecs_target]
}



resource "aws_appautoscaling_policy" "ecs_target_memory" {
  name               = "application-scaling-policy-memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = 50
  }
  depends_on = [aws_appautoscaling_target.ecs_target]
}
