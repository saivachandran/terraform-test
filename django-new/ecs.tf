# cluster
resource "aws_ecs_cluster" "example-cluster" {
  name = "example-tc"
}

#resource "aws_launch_configuration" "ecs-example-launchconfig-1" {
#  name_prefix          = "ecs-launchconfig-1"
#  image_id           = "ami-05df77ec905ed3dcf"
#  spot_price    = "0.0149"
#  instance_type = "t3a.medium"
#  key_name             = "infra-test"
#  iam_instance_profile = "ecsInstanceRole" #"ecs-ec2-role"#"arn:aws:iam::176569164197:role/ecs-ec2-role" #aws_iam_instance_profile.ecs-ec2-role.id
#  security_groups      = [aws_security_group.ecs-securitygroup.id]
#  user_data            = "#!/bin/bash\necho 'ECS_CLUSTER=example-tc' > /etc/ecs/ecs.config"
#  lifecycle {
#    create_before_destroy = true
#  }
#

resource "aws_launch_template" "ecs-example-launch-template-1" {
  name          = "ecs-launchtemplate-1"
  image_id           = "ami-05df77ec905ed3dcf"
  #spot_price    = "0.0149"
  instance_type = "t3a.medium"
  key_name             = "infra-test"
  iam_instance_profile  { name = "ecsInstanceRole" }
  vpc_security_group_ids      = [aws_security_group.ecs-securitygroup.id]
  user_data            = filebase64("${path.module}/run.sh")
  #lifecycle {
  #  create_before_destroy = true
  #}
}



resource "aws_autoscaling_group" "example-cluster-1a" {
  name                 = "example-cluster-1a"
  vpc_zone_identifier  = [aws_subnet.main-public-1.id, aws_subnet.main-public-2.id]
  #launch_configuration = aws_launch_configuration.ecs-example-launchconfig-1.name
  launch_template {
    id      = aws_launch_template.ecs-example-launch-template-1.id
    version = "$Latest"
  }
  desired_capacity     = 0
  min_size             = 0
  max_size             = 3
  tag {
    key                 = "Name"
    value               = "ecs-ec2-container"
    propagate_at_launch = true
  }
}


#resource "aws_launch_configuration" "ecs-example-launchconfig-2" {
#  name_prefix          = "ecs-launchconfig-2"
#  image_id           = "ami-05df77ec905ed3dcf"
#  instance_type = "t3a.medium"
#  key_name             = "infra-test"
#  iam_instance_profile = "ecsInstanceRole"#"ecs-ec2-role"#"arn:aws:iam::176569164197:role/ecs-ec2-role" #aws_iam_instance_profile.ecs-ec2-role.id
#  #iam_instance_profile = "arn:aws:iam::176569164197:role/ecs-ec2-role" #aws_iam_instance_profile.ecs-ec2-role.id
#  security_groups      = [aws_security_group.ecs-securitygroup.id]
#  user_data            = "#!/bin/bash\necho 'ECS_CLUSTER=example-cluster' > /etc/ecs/ecs.config"
#  lifecycle {
#    create_before_destroy = true
#  }
#}
#}

resource "aws_launch_template" "ecs-example-launch-template-2" {
  name          = "ecs-launchtemplate-2"
  image_id           = "ami-05df77ec905ed3dcf"
  #spot_price    = "0.0149"
  instance_type = "t3a.medium"
  key_name             = "infra-test"
  iam_instance_profile  { name = "ecsInstanceRole" }
  vpc_security_group_ids      = [aws_security_group.ecs-securitygroup.id]
  user_data            = filebase64("${path.module}/run.sh")
  #lifecycle {
  #  create_before_destroy = true
  #}
}

resource "aws_autoscaling_group" "example-cluster-2a" {
  name                 = "example-cluster-2a"
  vpc_zone_identifier  = [aws_subnet.main-public-1.id, aws_subnet.main-public-2.id]
  #launch_configuration = aws_launch_configuration.ecs-example-launchconfig-2.name
  launch_template {
    id      = aws_launch_template.ecs-example-launch-template-2.id
    version = "$Latest"
  }
  desired_capacity     = 0
  min_size             = 0
  max_size             = 2
  tag {
    key                 = "Name"
    value               = "ecs-ec2-container"
    propagate_at_launch = true
  }
}



resource "aws_ecs_cluster_capacity_providers" "example-cluster-1" {
  cluster_name = aws_ecs_cluster.example-cluster.name

  capacity_providers = [aws_ecs_capacity_provider.example-cluster-1.name,aws_ecs_capacity_provider.example-cluster-2.name]

  #default_capacity_provider_strategy {
  #  base              =  2
  #  weight            =  0
  #  capacity_provider = aws_ecs_capacity_provider.example-cluster-1.name
  #}
  #default_capacity_provider_strategy {
  #  base              =  0
  #  weight            =  1
  #  capacity_provider = aws_ecs_capacity_provider.example-cluster-2.name
  #}


}

resource "aws_ecs_capacity_provider" "example-cluster-1" {
  name = "example-cluster-1a-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.example-cluster-1a.arn

    managed_scaling {
      maximum_scaling_step_size = 5
      minimum_scaling_step_size = 1 
      status                    = "ENABLED"
      #instance_warmup_period    = 60
      target_capacity           = 100
    }
  }
}




resource "aws_ecs_capacity_provider" "example-cluster-2" {
  name = "example-cluster-2a-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.example-cluster-2a.arn

    managed_scaling {
      maximum_scaling_step_size = 5
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      #instance_warmup_period    = 60
      target_capacity           = 100
    }
  }
}

