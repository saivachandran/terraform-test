# app

data "template_file" "django-task-definition-template" {
  template = file("templates/app.json.tpl")
  vars = {
    REPOSITORY_URL = "176569164197.dkr.ecr.ap-south-1.amazonaws.com/tc_test"
    #replace(aws_ecr_repository.tc_test1.repository_url, "https://", "")
  }
}

resource "aws_ecs_task_definition" "django-task-definition" {
  family                = "django"
  container_definitions = data.template_file.django-task-definition-template.rendered
}

resource "aws_lb" "test-alb" {
  name = "test-alba"
  internal = false
  load_balancer_type = "application"
  #listener {
  #  instance_port     = 8000
  #  instance_protocol = "http"
  #  lb_port           = 80
  #  lb_protocol       = "http"
  #}

  #health_check {
  #  healthy_threshold   = 3
  #  unhealthy_threshold = 3
  #  timeout             = 30
  #  target              = "HTTP:8000/"
  #  interval            = 60
  #}

  #cross_zone_load_balancing   = true
  #idle_timeout                = 400
  #connection_draining         = true
  #connection_draining_timeout = 400

  subnets         = [aws_subnet.main-public-1.id, aws_subnet.main-public-2.id]
  security_groups = [aws_security_group.myapp-elb-securitygroup.id]

  tags = {
    Name = "test-alba"
  }
}

resource "aws_lb_listener" "test-alb-listener" {
  load_balancer_arn = aws_lb.test-alb.arn
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

resource "aws_ecs_service" "django-service" {
  name            = "django"
  cluster         = aws_ecs_cluster.example-cluster.id
  task_definition = aws_ecs_task_definition.django-task-definition.arn
  desired_count   = 2
  #iam_role        = "arn:aws:iam::176569164197:role/ecs-service-role" #aws_iam_role.ecs-service-role.arn
  #depends_on      = [aws_iam_policy_attachment.ecs-service-attach1]
  depends_on = [aws_lb_listener.test-alb-listener]
  force_new_deployment               = true
  load_balancer {
    #elb_name       = "test-alb" #aws_elb.test-alb.name
    container_name = "django"
    container_port = 4000
    target_group_arn = aws_lb_target_group.alb_tg.id

  }

 

 lifecycle {
    ignore_changes = [
      capacity_provider_strategy,
      desired_count
    ]
  }
  capacity_provider_strategy {
    base              =  1
    weight            =  0
    capacity_provider = aws_ecs_capacity_provider.example-cluster-a.name
  }

  capacity_provider_strategy {
    base              =  0
    weight            =  1
    capacity_provider = aws_ecs_capacity_provider.example-cluster-b.name
  }
 
}


resource "aws_ecs_service" "celery-service" {
  name            = "celery"
  cluster         = aws_ecs_cluster.example-cluster.id
  task_definition = aws_ecs_task_definition.django-task-definition.arn
  desired_count   = 2
  #iam_role        = "arn:aws:iam::176569164197:role/ecs-service-role" #aws_iam_role.ecs-service-role.arn
  #depends_on      = [aws_iam_policy_attachment.ecs-service-attach1]
  #depends_on = [aws_lb_listener.test-alb-listener]
  force_new_deployment               = true
  #load_balancer {
    #elb_name       = "test-alb" #aws_elb.test-alb.name
    #container_name = "django"
    #container_port = 4000
    #target_group_arn = aws_lb_target_group.alb_tg.id

  #}



 lifecycle {
    ignore_changes = [
      capacity_provider_strategy,desired_count
    ]
  }
  capacity_provider_strategy {
    base              =  1
    weight            =  0
    capacity_provider = aws_ecs_capacity_provider.example-cluster-c.name
  }

  capacity_provider_strategy {
    base              =  0
    weight            =  1
    capacity_provider = aws_ecs_capacity_provider.example-cluster-d.name
  }

}


#
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 3
  min_capacity       = 1 
  resource_id        = "service/${aws_ecs_cluster.example-cluster.name}/${aws_ecs_service.django-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_target" "ecs_target1" {
  max_capacity       = 3
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.example-cluster.name}/${aws_ecs_service.celery-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

#
#
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

resource "aws_appautoscaling_policy" "ecs_target1" {
  name               = "application-scaling-policy-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target1.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target1.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target1.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 50
  }
  depends_on = [aws_appautoscaling_target.ecs_target1]
}
#
#
#
#resource "aws_appautoscaling_policy" "ecs_target_memory" {
#  name               = "application-scaling-policy-memory"
#  policy_type        = "TargetTrackingScaling"
#  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
#  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
#  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
#
#  target_tracking_scaling_policy_configuration {
#    predefined_metric_specification {
#      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
#    }
#    target_value = 50
#  }
#  depends_on = [aws_appautoscaling_target.ecs_target]
#}
#
resource "aws_lb_target_group" "alb_tg" {
  name     = "example-tc-lb-tga"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

##  depends_on = [aws_alb.ecs-load-balancer]
}
#
##resource "aws_lb_target_group_attachment" "test" {
##  target_group_arn = aws_lb_target_group.alb_tg.arn
##  target_id        = aws_instance.test.id
##  port             = 80
##}
