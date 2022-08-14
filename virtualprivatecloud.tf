###############VPC##################
resource "aws_vpc" "virtual1" {
    cidr_block =  "10.0.0.0/16"

    tags = {
      "name" = "vpc1"
    }
  
}
#############SUB-NET##############

resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.virtual1.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"

    tags = {
    Name = "Main"

  }
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.virtual1.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1c"

    tags = {
    Name = "Main"

  }
}


################## IGW ###############

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.virtual1.id

  tags = {
    Name = "main"
  }
}

########security gp#################


resource "aws_security_group" "securitygroup" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.virtual1.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

    ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  
  }
#   inbound rule 
  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
##############atteching routetable with subnet####################

resource "aws_route_table_association" "ac" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.routable.id
}

resource "aws_route_table_association" "ab" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.routable.id
}
###############ROUTETABLE#####################################
resource "aws_route_table" "routable" {
 vpc_id = aws_vpc.virtual1.id

  route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.gateway.id
  
  }

  tags = {
    Name = "example"
  
  }
}
