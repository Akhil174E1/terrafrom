resource "aws_key_pair" "deployer" {
  key_name   = "deployer"
  public_key = file("C:/Users/Dell/.ssh/terraform_key.pub")
}


resource "aws_security_group" "ssh_access" {
  name        = "ssh-access"
  description = "Allow SSH access for Terraform provisioners"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "example" {
  ami           = "ami-0521cb2d60cfbb1a6"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.ssh_access.id]

  provisioner "file" {
    source      = "D:/Codingfolder/MoneyCal/target/MoneyCal-0.0.1-SNAPSHOT.jar"
    destination = "/tmp/MoneyCal-0.0.1-SNAPSHOT.jar"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("C:/Users/Dell/.ssh/terraform_key")
    host        = self.public_ip
  }
  tags = {
    Name = "FileprovisionerExample"
  }
}


