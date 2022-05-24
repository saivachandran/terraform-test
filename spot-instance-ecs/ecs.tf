# cluster
resource "aws_ecs_cluster" "example-cluster" {
  name = "example-cluster"
}

resource "aws_launch_configuration" "ecs-example-launchconfig" {
  name_prefix          = "ecs-launchconfig"
  image_id           = "ami-076bbae7511f2cc74"
  spot_price    = "0.0149"
  instance_type = "t2.medium"
  key_name             = "infra-test"
  iam_instance_profile = aws_iam_instance_profile.ecs-ec2-role.id
  security_groups      = [aws_security_group.ecs-securitygroup.id]
  user_data            = "#!/bin/bash\necho 'ECS_CLUSTER=example-cluster' > /etc/ecs/ecs.config\nstart ecs"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs-example-autoscaling" {
  name                 = "ecs-example-autoscaling"
  vpc_zone_identifier  = [aws_subnet.main-public-1.id, aws_subnet.main-public-2.id]
  launch_configuration = aws_launch_configuration.ecs-example-launchconfig.name
  desired_capacity   = 2
  min_size             = 2
  max_size             = 2
  tag {
    key                 = "Name"
    value               = "ecs-ec2-container"
    propagate_at_launch = true
  }
}

