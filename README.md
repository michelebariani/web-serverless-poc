# Intro
A simple Proof of Concept for a lightweight web application running in AWS and based on API Gateway, Lambda, DynamoDB.
Application code is written in Python, while AWS setup is based on terraform.
Basic CI is implemented as a GitHub Action.


# Architecture
The Python application (running as a Lambda function) supports receiving an HTTP GET request (handled by API Gateway) and retrieves a welcome message from a database (implemented as a DynamoDB table).

Multiple runtime environments are supported (such as "dev" and "prod") and set up via terraform.

Via GitHub Action it is possible to automatically update the Python code running in either "dev" or "prod" environments when a *git push* event occurs on either "dev" or "main" branches respectively.
Branch protection could be set up in the GitHub repo to ensure that no direct push is allowed for those branches, effectively ensuring that the code update takes place only upon merged PRs.


# Repo structure
[.github/](.github/) (actually [.github/workflows/](.github/workflows/)) folder hosts the Github Action(s)

[python/](python/) folder hosts the application code (the handler for the Lambda function)

[terraform/](terraform/) folder hosts the infrastructure as code to set up all runtime environments in AWS.
A [terraform/welcome/](terraform/welcome/) subfolder implements as a local terraform module everything needed for a single runtime environment, that then gets instantiated multiple times (see file [terraform/main.tf](terraform/main.tf))


# Requirements and configuration

## Python
Python application relies on a Python 3.9 runtime within Lambda. If you want to locally develop/test it on your machine, you should have Python 3.9 installed

## Terraform
Terraform code is to be run on your local laptop (or any VM) and relies on terraform 1.2.x to be installed.

AWS credentials need to be available (see https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration if you are not familiar on how to set them up for terraform), please note that the code currently assumes region *eu-central-1* to be used (see file [terraform/settings.tf](terraform/settings.tf)).
For simplicity I used an AWS account with very broad permission (it will need to provision quite a variety of objects).

Terraform also sets up the IAM user (*github_deploy*) to be then used within the GitHub Action.
You may choose to manually create an AWS Access Key for it, or optionally have terraform create it for you (just set to 1 variable *create_and_show_github_deploy_secrets* in file [terraform/settings.tf](terraform/settings.tf)).
Be aware that for this simple POC the provisioned AWS Access Key pair (id and secret) are stored in clear in terraform state file (stored in the machine running terraform), and displayed (also in clear) in the output.

## GitHub Repo (and Action)

AWS credentials need to be available in the GitHub Action automation to enable deploying new code to the Lambda function(s) previously set up via terraform.
In your GitHib repo, go to *Settings -> Secrets -> Actions* and set the following secrets with a valid AWS Acces Key (whether manually created or provisioned via terraform):
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY


# Usage

## Terraform
To run terraform, on a shell-featuring system (I personally use a Linux laptop) just run the following sequence of commands:

```
cd terraform
terraform init
terraform apply
```

The output will include URLs for the different environments that have been provisioned, e.g. (your output will be different)

```
urls = [
  "https://hriktflj0i.execute-api.eu-central-1.amazonaws.com/dev/welcome",
  "https://pg3qqv0b1d.execute-api.eu-central-1.amazonaws.com/prod/welcome",
]
```

Only an initial code/data setup is performed for Python code and DynamoDB table.
So later changes to that code/data (e.g. by deployment of new Python code via GitHub Acion) are not overwritten when running terraform again.


## GitHub Action

The Action gets automatically triggered upon any push on either "dev" or "main" branches


# Clean up

When you are done playing around with it, do not forget to clean up the AWS infrastructure so not to risk any unwanted cost.
On a shell-featuring system just run:

```
cd terraform
terraform destroy
```


## Further ideas/improvements

- CI could be extended also to terraform, using remote state file(s) (S3 + DynamoDB, as per https://www.terraform.io/language/settings/backends/s3) and one different terraform workspace (see https://www.terraform.io/language/state/workspaces) for each target environment. This would allow to have different IaC code for each environment.
- IAM permissions could likely be refined (restricted) for AWS user used for provisioning via terraform
- IAM permissions could likely be refined (restricted) for *github_deploy* AWS user
