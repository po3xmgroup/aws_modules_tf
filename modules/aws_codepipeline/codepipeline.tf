resource "aws_codepipeline" "codepipeline" {
  name     = var.pipeline_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = var.s3_bucket_name
    type     = "S3"


  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      region           = "us-east-1"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      namespace        = "SourceVariables"

      configuration = {
        ConnectionArn        = var.connection_arn
        FullRepositoryId     = var.gh_repository_id
        BranchName           = var.branch_name
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }



  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      region          = "us-east-1"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["SourceArtifact"]
      namespace       = "DeployVariables"
      version         = "1"

      configuration = {
        Extract    = "true"
        BucketName = var.s3_bucket_name
      }
    }
  }
}



resource "aws_iam_role" "codepipeline_role" {
  name = var.pipeline_role_name

  assume_role_policy = <<EOF
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

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = var.codepolicy_name
  role = aws_iam_role.codepipeline_role.id

  policy = templatefile("../../templates/policy.json", { aws_codepipeline = "tf-test-pipeline" })

}
