# RDS usage - WIP

Deploy a mySQL RDS instance and use mySQL dbs stored in it through a local node.js application.

|------|---------|
| Time to deploy | 8 min (with backup) / (?) min (without backup) |
| Estimated cost | 0,03 €/h |

## Useful links

[AWS RDS site](https://docs.aws.amazon.com/rds/index.html?nc2=h_ql_doc_rds)

## Usage

### Set db Credentials

Set user and password in `set_db_credentials.sh` script and than run it
```
. ./set_db_credentials.sh
```

Now you can deploy the db instance with terraform. Remember that at the and of the terraform deployment phase you have to copy/paste the `this_db_instance_endpoint` output variable (without the port number) in `dbsees.js` and `index.js`.

### Deploy RDS instance

To run this example you need to execute:

```
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money (AWS Elastic IP, for example). Run `terraform destroy` when you don't need these resources.

### Set-up node.js app

Before to do this step you have to deploy an RDS mySQL instance.

If you do not have npm yet installed please follow this [guide](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm).

Update `dbseed.js` and `index.js` with your RDS inputs (if you user the `set_db_credentials.sh` script you just need to update `<your-db-endpoint>`):
```
const con = mysql.createConnection({
    host: "<your-db-endpoint>",                  //Find this info in the db panel Connectivity&Security
    user: "<admin-name>",                        //The user name you defined during provisioning
    password: "<your-rds-instance-password>"     //The password you defined during provisioning
});
```
Run `dbseed.js` to create the table
```
node dbseed.js
```
You should get a message like this
```
OkPacket {
  fieldCount: 0,
  affectedRows: 0,
  insertId: 0,
  serverStatus: 2,
  warningCount: 1,
  message: '',
  protocol41: true,
  changedRows: 0 }
```
Now that you have created the main table you can run your code
```
node index.js
```
On your preferred browser, go to `localhost:3000/views`, you should see a screen like this (with zero rows because it is still empty)

![appview](./images/appview.png)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.21 |
| aws | >= 2.68 |
| node | >= 10.13.0 |
| npm | >= 6.4.1 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.68 |

## Inputs

| Name | Description |
|------|---------|
| awsusername | Aws username |
| db_username | db username |
| db_password | db password |

## Outputs

| Name | Description |
|------|-------------|
| this\_db\_instance\_address | The address of the RDS instance |
| this\_db\_instance\_arn | The ARN of the RDS instance |
| this\_db\_instance\_availability\_zone | The availability zone of the RDS instance |
| this\_db\_instance\_endpoint | The connection endpoint |
| this\_db\_instance\_hosted\_zone\_id | The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record) |
| this\_db\_instance\_id | The RDS instance ID |
| this\_db\_instance\_name | The database name |
| this\_db\_instance\_password | The database password (this password may be old, because Terraform doesn't track it after initial creation) |
| this\_db\_instance\_port | The database port |
| this\_db\_instance\_resource\_id | The RDS Resource ID of this instance |
| this\_db\_instance\_status | The RDS instance status |
| this\_db\_instance\_username | The master username for the database |
| this\_db\_parameter\_group\_arn | The ARN of the db parameter group |
| this\_db\_parameter\_group\_id | The db parameter group id |
| this\_db\_subnet\_group\_arn | The ARN of the db subnet group |
| this\_db\_subnet\_group\_id | The db subnet group name |


<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
