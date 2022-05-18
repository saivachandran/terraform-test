variable "AWS_REGION" {
  default = "ap-south-1"
}



variable "AMIS" {
  type = map(string)
  default = {
    ap-south-1 = "ami-05ba3a39a75be1ec4"
  }
}

