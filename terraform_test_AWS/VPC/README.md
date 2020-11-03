# Complete VPC architecture

Configuration in this directory creates set of VPC resources which may be sufficient for staging or production environment. This example has been developed starting from [simple-vpc](../../modules_AWS/terraform-aws-vpc-master/examples/complete-vpc).

We are trying to replicate the following network layout (with some changes):
![AWS network diagram](https://aws-quickstart.github.io/quickstart-aws-vpc/images/architecture_diagram.png)

Main changes:
- This network layout is deployed in eu-central-1 region that has just three availability zones.
- We changes Private Subnet B with Database subnet

## Useful links
VPC on AWS Quickstart - https://aws-quickstart.github.io/quickstart-aws-vpc/

AWS SINGLE VPC DESIGN - http://d0.awsstatic.com/aws-answers/AWS_Single_VPC_Design.pdf

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money (AWS Elastic IP, for example). Run `terraform destroy` when you don't need these resources.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.21 |
| aws | >= 2.68 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.68 |

## Inputs

No input.

## Outputs

| Name | Description |
|------|-------------|
| cgw\_ids | List of IDs of Customer Gateway |
| database\_subnets | List of IDs of database subnets |
| elasticache\_subnets | List of IDs of elasticache subnets |
| intra\_subnets | List of IDs of intra subnets |
| nat\_public\_ips | List of public Elastic IPs created for AWS NAT Gateway |
| private\_subnets | List of IDs of private subnets |
| public\_subnets | List of IDs of public subnets |
| redshift\_subnets | List of IDs of redshift subnets |
| this\_customer\_gateway | Map of Customer Gateway attributes |
| vpc\_endpoint\_ssm\_dns\_entry | The DNS entries for the VPC Endpoint for SSM. |
| vpc\_endpoint\_ssm\_id | The ID of VPC endpoint for SSM |
| vpc\_endpoint\_ssm\_network\_interface\_ids | One or more network interfaces for the VPC Endpoint for SSM. |
| vpc\_id | The ID of the VPC |


<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
