# ##############code for pipeine############################3
resource "aws_codepipeline" "djangoCodePipeline" {
  name = "djangoCodePipeline"
  role_arn = aws_iam_role.codepipelinerole.arn

  artifact_store {
    location = aws_s3_bucket.bucket.bucket
    type = "S3"
  }

  stage {
    name = "Source"

    action {
      name = "name"
      category = var.category
      owner = "ThirdParty"
      provider = "GitHub"
      version = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        OAuthToken = var.github_token
        Owner = var.github_owner
        Repo = var.github_repo
        Branch = var.branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name = "Build"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]

      configuration = {
        ProjectName = aws_codebuild_project.codebuildproject.name
      }
    }
  }

  stage {
    name = "Deploy_to_EC2"

    action {
      name = "Deploy"
      category = "Deploy"
      owner = "AWS"
      provider = "CodeDeploy"
      input_artifacts = ["BuildArtifact"]
      version = "1"

      configuration = {
      ApplicationName    = aws_codedeploy_app.codedeployapp.name 
      DeploymentGroupName = aws_codedeploy_deployment_group.codedeploygroup.deployment_group_name  
    }
    }
  }
  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["SourceArtifact"]
      version         = "1"
 
      configuration = {
        BucketName = aws_s3_bucket.bucket.bucket
        Extract = "true"
      }
    }
  }
}

###############DECLARING VERIABLE#################

variable "github_token" {
  type        = string
  description = "Github OAuth token"
   default     = "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"
}

variable "github_owner" {
  type        = string
  description = "Github username"
  default     = "harshhhit"

}

variable "branch" { 
  type        = string
  description = "branch name"
  default="master"
}

variable "github_repo" {
  type        = string
  description = "Github repo"
   default     = "djangot2"
}

variable "category" {
  description = "AWS resource category"
  type = string
  default = "Source"
}



##################veriable###############

##################WEABHOOK###################33
# webhot for github
resource "aws_codestarconnections_connection" "gitwebhook" {
  name          = "gitwebhook"
  provider_type = "GitHub"
}

######################codepiplinerole######################

#role for code pipeline

resource "aws_iam_role" "codepipelinerole" {
  name                 = "codepipelinerole"
  assume_role_policy   = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

##################policy #######################3
resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = aws_iam_role.codepipelinerole.id

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



