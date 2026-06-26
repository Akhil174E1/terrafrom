variable "instancename"{
    type = list(string)
    default = ["WebServer1", "WebServer2", "WebServer3"]
}



resource "aws_instance" "web" {
  ami           = "ami-0521cb2d60cfbb1a6"
  instance_type = "t2.micro"
  count         = length(var.instancename)

  tags = {
    Name = element(var.instancename, count.index)
  }
}