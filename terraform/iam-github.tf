#
# IAM for (e.g.) GitHub Actions
#

data "aws_iam_policy_document" "github_deploy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "github_deploy" {
  name               = "github_deploy"
  assume_role_policy = data.aws_iam_policy_document.github_deploy.json
}

resource "aws_iam_user" "github_deploy" {
  name = "github_deploy"
}

resource "aws_iam_policy_attachment" "github_deploy" {
  name       = "github_deploy"
  users      = [aws_iam_user.github_deploy.name]
  roles      = [aws_iam_role.github_deploy.name]
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

resource "aws_iam_access_key" "github_deploy" {
  count = var.create_and_show_github_deploy_secrets

  user = aws_iam_user.github_deploy.name
}

output "github_key" {
  value = [for item in aws_iam_access_key.github_deploy : [item.id, nonsensitive(item.secret)]]
}
