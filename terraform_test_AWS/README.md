# AWS tests

Here you can find many different deployment with terraform and ansible.
We are extensively using these terraform [modules](../modules_AWS).

Have a look to [this](https://learn.hashicorp.com/tutorials/terraform/aws-build) brief guide about terraform, if you are a beginner using terraform on AWS.

This is the list of the available tests with a short description. Click on one of them if you are interested to examine in depth (each test has its own README file).

- [DNS](./DNS);
  - **Status**, work in progress
  - **Description**, xxxxx
- [IAM](./IAM):
  - **Status**, work in progress
  - **Description**, xxxxx
- [VPC](./VPC):
  - **Status**, work in progress
  - **Description**, xxxxx

## Install and configure terraform

Have look to this [guide](https://learn.hashicorp.com/tutorials/terraform/install-cli) to set-up your terraform environment.

## Install and configure ansible

Have look to this [guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) to set-up your ansible environment.

## Configure AWS credentials locally

In order to run terraform and/or ansible commands you have to export AWS crediantals in your local environment. Run the following commands from CLI:
```
export AWS_ACCESS_KEY_ID=xxxxxxxxxxxxxxx
export AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxx
```
If you are the administrator/owner of your AWS account you can generate the access key from the AWS web-console. Go to *Users* and select your user (if you did not create your first user please do it and assign him administrative access). Go to the panel *Security Credentials* and click on *Create access key* button.

If you are not the administrator/owner of the AWS account, contact your AWS account administrator to get the access keys.
