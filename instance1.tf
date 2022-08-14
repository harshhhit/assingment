resource "aws_instance" "ubuntu1" {
    ami = "ami-08d4ac5b634553e16"
    instance_type = "t2.micro"
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.securitygroup.id]
    iam_instance_profile =  aws_iam_instance_profile.ec2profile.name
    subnet_id = aws_subnet.subnet1.id
    user_data = <<-EOF
                    #!/bin/bash

                    sudo apt update -y
                    sudo apt install ruby-full -y
                    sudo apt install wget -y 
                    sudo wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
                    sudo chmod +x ./install
                    sudo ./install auto  
                    sudo service codedeploy-agent status 
                    sudo service codedeploy-agent restart

                    EOF
   
     tags = {
    Name = "Deployment"
  }

}

resource "aws_iam_role_policy" "codepipeline_policyForEc2" {
  name = "codepipeline_policyForEc2"
  role = aws_iam_role.instancerole.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::*/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild",
        "codedeploy:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

#role for ec2 instance

resource "aws_iam_role" "instancerole" {
  name = "test_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

# creating profile for ec2 and attach the above role
resource "aws_iam_instance_profile" "ec2profile" {
  name  = "ec2profile1112"
  role = aws_iam_role.instancerole.name
}