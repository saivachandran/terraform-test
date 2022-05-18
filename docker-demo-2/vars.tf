variable "AWS_REGION" {
  default = "ap-south-1"
}



variable "ECS_INSTANCE_TYPE" {
  default = "t2.micro"
}

variable "ECS_AMIS" {
  type = map(string)
  default = {
    ap-south-1 = "ami-076bbae7511f2cc74"
  }
}

# Full List: http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
