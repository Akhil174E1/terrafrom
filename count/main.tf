variable     "sgrules" {
    type = list(string)
    default = ["22", "80", "443"]
}



variable     "sgmapvalues" {
    type = map(string)
   default = {
    22 = "10.0.0.0/8"
    80 = "10.0.0.0/16"
    443 = "10.0.0.0/24"
   }
}

resource "aws_security_group" "demo_sg" {
    name        = "demo-security-group"
    description = "Security group for demo instance"


    ingress =[ 
         for port, cidr in var.sgmapvalues : {
        from_port   = tonumber(port)
        to_port     = tonumber(port)
        description = "Allow traffic on port ${port}"
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        security_groups = []
        self = false
        protocol    = "tcp"
        cidr_blocks = cidr != "" ? [cidr] : []

    }
    ]
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }


}

resource "aws_instance" "demo" {
    ami = "ami-0521cb2d60cfbb1a6"
    instance_type = "t2.micro"

    security_groups = [aws_security_group.demo_sg.name]

  
    tags = {
        Name = "DemoInstance"
    }
  
}