resource "aws_instance" "demo"{
    ami = "ami-08f44e8eca9095668"
    instance_type = t2.micro
}