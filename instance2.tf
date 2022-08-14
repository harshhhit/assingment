resource "aws_instance" "ubuntu2" {
    ami = "ami-08d4ac5b634553e16"
    instance_type = "t2.micro"
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.securitygroup.id]
    subnet_id = aws_subnet.subnet2.id
    user_data = <<-EOF
                    #!/bin/bash
                    sudo apt update 
                    sudo apt install apache2 -y
                    EOF
    

}