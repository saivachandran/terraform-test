
provider "aws" {

  region     = "ap-south-1"

}

resource "aws_instance" "import" {
   ami           = "ami-0756a1c858554433e"
  instance_type  = "t2.small"
  tags = {
    Name = "terraform-ec2"
  }

}

