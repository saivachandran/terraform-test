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



resource "aws_autoscaling_group" "example-cluster" {
  name                 = "example-cluster"
  vpc_zone_identifier  = [aws_subnet.main-public-1.id, aws_subnet.main-public-2.id]
  launch_configuration = aws_launch_configuration.ecs-example-launchconfig.name
  desired_capacity   = 0
  min_size             = 0
  max_size             = 5
  tag {
    key                 = "Name"
    value               = "ecs-ec2-container"
    propagate_at_launch = true
  }
}


resource "aws_launch_configuration" "ecs-example-launchconfig1" {
  name_prefix          = "ecs-launchconfig1"
  image_id           = "ami-076bbae7511f2cc74"
  instance_type = "t2.medium"
  key_name             = "infra-test"
  iam_instance_profile = aws_iam_instance_profile.ecs-ec2-role.id
  security_groups      = [aws_security_group.ecs-securitygroup.id]
  user_data            = "#!/bin/bash\necho 'ECS_CLUSTER=example-cluster' > /etc/ecs/ecs.config\nstart ecs"
  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_autoscaling_group" "example-cluster1" {
  name                 = "example-cluster1"
  vpc_zone_identifier  = [aws_subnet.main-public-1.id, aws_subnet.main-public-2.id]
  launch_configuration = aws_launch_configuration.ecs-example-launchconfig1.name
  desired_capacity   = 0
  min_size             = 0
  max_size             = 5
  tag {
    key                 = "Name"
    value               = "ecs-ec2-container"
    propagate_at_launch = true
  }
}


resource "aws_ecs_cluster_capacity_providers" "example-cluster" {
  cluster_name = aws_ecs_cluster.example-cluster.name

  capacity_providers = [aws_ecs_capacity_provider.example-cluster.name]

  default_capacity_provider_strategy {
    base              =  4
    weight            =  2 
    capacity_provider = aws_ecs_capacity_provider.example-cluster.name
  }

}

resource "aws_ecs_capacity_provider" "example-cluster" {
  name = "example-cluster"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.example-cluster.arn

    managed_scaling {
      maximum_scaling_step_size = 10
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      instance_warmup_period    = 60
      target_capacity           = 75
    }
  }
}



resource "aws_ecs_cluster_capacity_providers" "example-cluster1" {
  cluster_name = aws_ecs_cluster.example-cluster.name

  capacity_providers = [aws_ecs_capacity_provider.example-cluster1.name]

  default_capacity_provider_strategy {
    base              =  0
    weight            =  2
    capacity_provider = aws_ecs_capacity_provider.example-cluster1.name
  }

}



resource "aws_ecs_capacity_provider" "example-cluster1" {
  name = "example-cluster1"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.example-cluster1.arn

    managed_scaling {
      maximum_scaling_step_size = 10
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      instance_warmup_period    = 60
      target_capacity           = 75
    }
  }
}


