# Intro
A simple Proof of Concept for a lightweight web application running in AWS and based on API Gateway, Lambda, DynamoDB.
Application code is written in Python, while AWS setup is based on terraform.
Basic CI is implemented as a GitHub Action.


# Architecture
The Python application (running as a Lambda function) supports receiving an HTTP GET request (handled by API Gateway) and retrieves a welcome message from a database (implemented as a DynamoDB table).

Multiple runtime environments are supported (currently "dev" and "prod", yet they could be more) for different branches ("dev" and "main" respectively). Each environment is automatically set up / reconciled by GitHub Actions via terraform (multiple workspaces on a remote backend leveraging on S3 and DynamoDB).

The trigger for GitHub Actions is any *git push* event on either "dev" or "main" branches.
Branch protection could be set up in the GitHub repo to ensure that no direct push is allowed for those branches, effectively ensuring that the code update takes place only upon merged PRs.


# Repo structure
[.github/](.github/) (actually [.github/workflows/](.github/workflows/)) folder hosts the Github Actions

[python/](python/) folder hosts the application code (the handler for the Lambda function)

[terraform-setup-remote/](terraform-setup-remote/) folder hosts some extra infrastructure as code that can be used to set up AWS resources needed for a remote backend to be available for the main terraform folder used in GitHub Actions.
Alternatively, the remote backend can be manually setup as per https://www.terraform.io/language/settings/backends/s3), also enabling lock via DynamoDB.

[terraform/](terraform/) folder hosts the infrastructure as code to set up all runtime environments in AWS. This is the terraform folder used in GitHub Actions.
A [terraform/welcome/](terraform/welcome/) subfolder implements as a local terraform module everything needed for a single generic environment, that then gets instantiated with proper parameters depending on the branch/workspace (see file [terraform/main.tf](terraform/main.tf))


# Requirements and configuration

## Python
Python application relies on a Python 3.9 runtime within Lambda. If you want to locally develop/test it on your machine, you should have Python 3.9 installed

## AWS
Please note that the code currently assumes **AWS region *eu-central-1*** to be used (see files [.github/workflows/CI.yml](.github/workflows/CI.yml), [.github/workflows/destroy.yml](.github/workflows/destroy.yml), [terraform/settings.tf](terraform/settings.tf), [terraform-setup-remote/settings.tf](terraform-setup-remote/settings.tf)).

An AWS account is needed with **permissions including the following policies**:
* AmazonDynamoDBFullAccess
* AmazonAPIGatewayAdministrator
* AmazonS3FullAccess
* AWSLambda_FullAccess
* IAMFullAccess

Note: these permissions could likely be refined (restricted) a bit.

An **AWS Access Key pair** (Id and Secret) is to be created for this user and used for your local terraform (if any) and for the GitHub Repo, as follows.

## Terraform
A remote backend based on **S3 needs a unique bucket name**, so you need to replace current value *michelebariani-terraform* with something of your own in files [terraform/settings.tf](terraform/settings.tf), [terraform-setup-remote/settings.tf](terraform-setup-remote/settings.tf).

If you choose to setup the remote backend manually (via AWS GUI or AWS CLI, and as per as per https://www.terraform.io/language/settings/backends/s3), no terraform needs to be installed locally.

The only terraform to be (optionally) run on your local laptop (or any VM) is the one in [terraform-setup-remote/](terraform-setup-remote/) to set up the above mentioned remote backend. It relies on terraform 1.2.x to be installed.

If you choose to run the setup with a local terraform, it needs **AWS credentials** to be available (see https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration if you are not familiar on how to set them up).
See also the previous AWS section.

**Whether you set it up manually or via (local) terraform, the remote backend must be setup before GitHub Actions successfully set up / reconcile anything.**

## GitHub Repo (and Action)

**AWS credentials** need to be available in the GitHub Action automation to enable set up / reconciliation via terraform.

In your GitHib repo, go to *Settings -> Secrets -> Actions* and set the following secrets with a valid AWS Acces Key (see also the previous AWS section):
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY


# Usage

## Terraform (optional)
To locally run terraform for the remote backend setup, on a shell-featuring system (I personally use a Linux laptop) just run the following sequence of commands:

```
cd terraform-setup-remote
terraform init
terraform apply
```

## GitHub Action

The *CI* workflow gets automatically triggered upon any push on either "dev" or "main" branches

A successful workflow run will include a **job summary providing the URL** for the reconciled environment, e.g. (your output will be different)

```
prod url: https://zdy9ed2x5e.execute-api.eu-central-1.amazonaws.com/prod/welcome
```

# Clean up

When you are done playing around with it, do not forget to clean up the AWS infrastructure so not to risk any unwanted cost.

To this end, an additional *destroy* workflow is available in GitHub Actions, to be manually triggered on either "dev" or "main" branches so to destroy all corresponding AWS resources.

Note: this is handy for a case study, for a real/production usage this workflow show not be easily triggered (or not event present).

After (and only after) having removed all AWS resources created by GitHib Actions you can also remove all AWS resources supporting the remote backend.
If you did so via local terraform, you need to manually empty your S3 bucket first (all object versions), then on a shell-featuring system just run:

```
cd terraform-setup-remote
terraform destroy
```
