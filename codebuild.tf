##################Codebuild policy #####################

resource "aws_iam_role_policy" "codebuildpolicy" {
  role = aws_iam_role.rolecodebuild.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterfacePermission"
      ],
      "Resource": [
        "arn:aws:ec2:us-east-1:123456789012:network-interface/*"
      ],
      "Condition": {
        "StringEquals": {
          "ec2:Subnet": [
            "${aws_subnet.subnet1.arn}",
            "${aws_subnet.subnet2.arn}"
          ],
          "ec2:AuthorizedService": "codebuild.amazonaws.com"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.bucket.arn}",
        "${aws_s3_bucket.bucket.arn}/*"
      ]
    }
  ]
}
POLICY
}


###############ROLE FOR CODEBUILD#####################
resource "aws_iam_role" "rolecodebuild" {
  name = "rolecodebuild"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
###############ROLE attachment#####################
resource "aws_iam_role_policy_attachment" "CodeDeployRoleattch" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.rolecodebuild.name
}
# AWSCodeDeployRole"
#code for code deploy project
###################################codebuild##############################
resource "aws_codebuild_project" "codebuildproject" {
  name          = "djangobuild-project"
  description   = "test_djangobuild_project"
  build_timeout = "5"

  service_role  = aws_iam_role.rolecodebuild.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }



  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

      environment_variable {
      name  = "djangobuild"
      value = "djangobuild"
    }

    }

    source {
    type            = "GITHUB"
    location        = "https://github.com/harshhhit/djangot2.git"
    git_clone_depth = 1
  }

  tags = {
    Environment = "Test"
  }

}

# policy for code build role
resource "aws_iam_role_policy" "srole" {
  role = aws_iam_role.rolecodebuild.name

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
        "s3:PutObject",
        "logs:CreateLogStream",
        "logs:DescribeLogStreams",
        "logs:PutRetentionPolicy",
        "logs:CreateLogGroup"
       
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