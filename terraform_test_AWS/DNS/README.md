# Create and configure a DNS server - WIP

This example has been developed starting from [VPC](../VPC).

We are trying to build and configure a DNS server. Read this [guide](https://badshah.io/how-i-hosted-a-dns-server-on-aws/) before start with this exercise.

## Useful links

[AWS DHCP options](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_DHCP_Options.html)

## Usage (Terraform part)

To run this example you need to execute:

```
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money (AWS Elastic IP, for example). Run `terraform destroy` when you don't need these resources.

## Usage (Ansible part)

### Generate dynamic AWS ec2 inventory with ansible

Download `ec2.py` and `ec2.ini` file and make `ec2.py` executable:

```
wget https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.py
wget https://raw.githubusercontent.com/ansible/ansible/stable-1.9/plugins/inventory/ec2.ini
chamod a+x ec2-py
```

To see the dynamic inventory of aws ec2 instances run:
```
./ec2.py --list
```

See this [link](https://aws.amazon.com/blogs/apn/getting-started-with-ansible-and-dynamic-amazon-ec2-inventory-management/) for more detailed instructions.

### Configure DNS server

We are using `bind9` to automate the setup of DNS zones ([link](https://help.ubuntu.com/community/BIND9ServerHowto)).
To install `bind9` run:
```
ansible-playbook -i ec2.py configure_bind9.yml -l tag_Name_dns_server
```
Update the `setup_DNS.sh` file with the right inputs (`zone`, `Nameservers` and `ElasticIP`).

Run the following command to configure the DNS server:
```
ansible-playbook -i ec2.py configure_DNS.yml -l tag_Name_dns_server
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.21 |
| aws | >= 2.68 |
| ansible | >= 2.9.1 |

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
