#   }########################codedeployrole##################

resource "aws_iam_role" "deployrole" {
  name = "deploypolicy"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}





resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.deployrole.name
}



########################codedeployapp##################
resource "aws_codedeploy_app" "codedeployapp" {
#compute_platform = "Server"
  name = "djangodeploy-app"
}




# resource "aws_sns_topic" "SNSdeployapp" {
#   name = "SNSdeployapp"
# }
########################codedeploygroup##################
resource "aws_codedeploy_deployment_group" "codedeploygroup" {
  app_name              = aws_codedeploy_app.codedeployapp.name
  deployment_group_name = "deploymentgroup"
  service_role_arn      = aws_iam_role.deployrole.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "Deployment"
    }
  }
}

#     ec2_tag_filter {
#       key   = "filterkey2"
#       type  = "KEY_AND_VALUE"
#       value = "filtervalue"
#     }
#   }

#   trigger_configuration {
#     trigger_events     = ["DeploymentFailure"]
#     trigger_name       = "example-trigger"
#     trigger_target_arn = aws_sns_topic.example.arn
#   }

#   auto_rollback_configuration {
#     enabled = true
#     events  = ["DEPLOYMENT_FAILURE"]
#   }

#   alarm_configuration {
#     alarms  = ["my-alarm-name"]
#     enabled = true
