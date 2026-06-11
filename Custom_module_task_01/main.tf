resource "aws_vpc" "cust_vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "cust_vpc"
    }
  
}

resource "aws_subnet" "bastion-01"{
    vpc_id = aws_vpc.cust_vpc.id
    cidr_block = "10.0.1.0/26"
    tags = {
        Name = "bastion-01"
    }  
}

resource "aws_subnet" "bastion-02"{
    vpc_id = aws_vpc.cust_vpc.id
    cidr_block = "10.0.2.0/26"
    tags = {
        Name = "bastion-02"
    }
}


resource "aws_subnet" "private-01"{
    vpc_id = aws_vpc.cust_vpc.id
    cidr_block = "10.0.3.0/26"
    tags = {
        Name = "private-01"
    }
}


resource "aws_subnet" "private-02"{
    vpc_id = aws_vpc.cust_vpc.id
    cidr_block = "10.0.4.0/26"
    tags = {
        Name = "private-02"
    }
}

resource "aws_security_group" "bastion_sg" {
    name        = "bastion_sg"
    description = "Security group for bastion host"
    vpc_id      = aws_vpc.cust_vpc.id

    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_instance" "bastion_host-01"{
    ami                         = "ami-00e801948462f718a"
    instance_type               = "t2.micro"
    associate_public_ip_address = true
    subnet_id                   = aws_subnet.bastion-01.id
    vpc_security_group_ids      = [aws_security_group.bastion_sg.id]

    tags = {
        Name = "bastion_host-01"
    }
}

resource "aws_instance" "bastion_host-02"{
    ami                         = "ami-00e801948462f718a"
    instance_type               = "t2.micro"
    associate_public_ip_address = true
    subnet_id                   = aws_subnet.bastion-02.id
    vpc_security_group_ids      = [aws_security_group.bastion_sg.id]

    tags = {
        Name = "bastion_host-02"
    }
}


resource "aws_instance" "private_ec2-01"{
    ami                    = "ami-00e801948462f718a"
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.private-01.id
    vpc_security_group_ids = [aws_security_group.bastion_sg.id]

    tags = {
        Name = "private_ec2-01"
    }
}


resource "aws_instance" "private_ec2-02"{
    ami                    = "ami-00e801948462f718a"
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.private-02.id
    vpc_security_group_ids = [aws_security_group.bastion_sg.id]

    tags = {
        Name = "private_ec2-02"
    }
}


resource "aws_internet_gateway" "cust_igw" {
    vpc_id = aws_vpc.cust_vpc.id

    tags = {
        Name = "cust_igw"
    }
}

resource "aws_eip" "nat_eip" {
    domain = "vpc"

    tags = {
        Name = "nat_eip"
    }
}

resource "aws_nat_gateway" "nat_gw" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id     = aws_subnet.bastion-01.id

    tags = {
        Name = "nat_gw"
    }

    depends_on = [aws_internet_gateway.cust_igw]
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.cust_vpc.id

    tags = {
        Name = "public_rt"
    }
}

resource "aws_route" "public_default_route" {
    route_table_id         = aws_route_table.public_rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.cust_igw.id
}

resource "aws_route_table_association" "public_bastion_01" {
    subnet_id      = aws_subnet.bastion-01.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_bastion_02" {
    subnet_id      = aws_subnet.bastion-02.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.cust_vpc.id

    tags = {
        Name = "private_rt"
    }
}

resource "aws_route" "private_default_route" {
    route_table_id         = aws_route_table.private_rt.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

resource "aws_route_table_association" "private_01" {
    subnet_id      = aws_subnet.private-01.id
    route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_02" {
    subnet_id      = aws_subnet.private-02.id
    route_table_id = aws_route_table.private_rt.id
}