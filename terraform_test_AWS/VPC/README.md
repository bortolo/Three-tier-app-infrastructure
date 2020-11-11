# Complete VPC architecture

Deploy a custom VPC with Route53 records and simple EC2 instances to test ping and ssh authentication.

 ![appview](./images/architecture.png)

 | Resource | Estimated cost (without VAT) | Link |
 |------|---------|---------|
 | EC2 | 0,13x3 $/h | [Pricing](https://aws.amazon.com/ec2/pricing/on-demand/) |
 | Route53 | if deleted within 12h no charges are applied | [Pricing](https://aws.amazon.com/route53/pricing/) |

 | Automation | Time |
 |------|---------|
 | terraform apply | 2min 30sec |
 | terraform destroy | 1min 30sec |

## Useful links

[AWS VPC site](https://aws.amazon.com/vpc/)

[AWS VPC User Guide](https://docs.aws.amazon.com/vpc/index.html)

[VPC on AWS Quickstart](https://aws-quickstart.github.io/quickstart-aws-vpc/)

[AWS SINGLE VPC DESIGN](http://d0.awsstatic.com/aws-answers/AWS_Single_VPC_Design.pdf)

## Usage

Generete your [public ssh key](https://www.ssh.com/ssh/keygen/) and update `main.tf` file with your `id_rsa.pub` in the field `public_key` of the `aws_key_pair` resource.
To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money. Run `terraform destroy` when you don't need these resources.

### How to test it

All the EC2 instances have public_ip enabled but only public_subnet is routed to the internet gateway. Therefore you will be able to reach only the public instance from your workstation (with both `ssh` or `ping` command).

If you log-in the public instance you can also try the Route53 records. Run the `ping` command using `database.example.com.private_host_zone` or `private.example.com.private_host_zone` instead of the IP address of the instances.

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
