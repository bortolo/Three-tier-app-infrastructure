# AWS tests

Here you can find many different deployments with terraform and ansible.
We are extensively using these terraform [modules](../modules_AWS), so please download also this folder to run with success the following examples.

Have a look to [this](https://learn.hashicorp.com/tutorials/terraform/aws-build) brief guide about terraform, if you are a beginner using terraform on AWS.

This is the list of the available tests with a short description. Click on one of them if you are interested to examine in depth.

- **[VPC](./VPC)**
  - **Status**, DONE (alpha)
  - **Description**, deploy a custom VPC and several EC2 instances to test route tables from remote workstation and inside AWS.
  - **AWS services**, VPC, Route53, EC2.
  - **other technologies**, terraform.
- **[IAM](./IAM)**
  - **Status**, WIP
  - **Description**, create several users and groups. Assign users to groups and upload custom policies.
  - **AWS services**, IAM.
  - **other technologies**, terraform.
- **[RDS with local front-end server](./RDS)**
  - **Status**, WIP
  - **Description**, deploy an RDS mysql instance and access it through a local node.js app.
  - **AWS services**, RDS.
  - **other technologies**, terraform, node.js, MySQL
- **[RDS with front-end server running on EC2 instance](./EC2andRDS)**
  - **Status**, WIP
  - **Description**, deploy an RDS instance and an EC2 instance. Configure EC2 instance with a node.js app similar to the one used in the previous example.
  - **AWS services**, Elastic IP, Route53, EC2, RDS.
  - **other technologies**, terraform, ansible, node.js, MySQL
- **[Manage RDS DB secrets with AWS SecretsManager](./SecretManager)**
  - **Status**, WIP
  - **Description**, deploy an example similar to the previous one and in addition manage the DB secrets with AWS SecretsManager.
  - **AWS services**, SecretsManager, IAM roles, Elastic IP, Route53, EC2, RDS.
  - **other technologies**, terraform, ansible, node.js, MySQL
- **[Deploy network loadbalancer](./Loadbalancer)**
  - **Status**, WIP
  - **Description**, deploy an example similar to the previous one and in addition add a network loadbalancer in front of the EC2 instances
  - **AWS services**, NLB, SecretsManager, IAM roles, Elastic IP, Route53, EC2, RDS.
  - **other technologies**, terraform, ansible, node.js, MySQL

## Getting started
### Install and configure terraform

Have look to this [guide](https://learn.hashicorp.com/tutorials/terraform/install-cli) to set-up your terraform environment.

### Install and configure ansible

Have look to this [guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) to set-up your ansible environment.

### Configure AWS credentials locally

In order to run terraform and/or ansible commands you have to export AWS crediantals in your local environment. Run the following commands from CLI:
```
export AWS_ACCESS_KEY_ID=xxxxxxxxxxxxxxx
export AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxx
```
If you are the administrator/owner of your AWS account you can generate the access key from the AWS web-console. Go to *Users* and select your user (if you did not create your first user please do it and assign him administrative access). Go to the panel *Security Credentials* and click on *Create access key* button.

If you are not the administrator/owner of the AWS account, contact your AWS account administrator to get the access keys.

**TIP,** to avoid to run each time these two commands just create a simple bash script like this one
```
#!/bin/sh
# echo "Setting environment variables for Terraform to use AWS"
export AWS_IAM_USER=<your-user-name>
export AWS_ACCESS_KEY_ID=<your-access-key-id>
export AWS_SECRET_ACCESS_KEY=<your-secret-access-key-id>
```
Save it as activateAWS.sh (don't store it in a shared repository) and make it executable:
```
chmod +x activateAWS.sh
```
Execute it everytime you open a new CLI session:
```
. ./activateAWS.sh
```
