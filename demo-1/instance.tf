provider "aws" {

  region     = "ap-south-1"

}

resource "aws_instance" "Terraform-automation" {

  ami            = "ami-05ba3a39a75be1ec4"
  instance_type  = "t2.micro"
  key_name       = "infra-test"

  tags = {
    Name = "terraform-ec2"
  }
  
}


