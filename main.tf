resource "aws_instance" "create_instance" {
  ami           = var.ami_id
  instance_type = var.insta_type

  tags = {
    Name = "ExampleInstance"
  }
  
}


