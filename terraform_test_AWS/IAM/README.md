# SET-UP IAM

This script deploys users and groups.
It is possible to set-up different policies for different groups.

## Add an user

Define a new user in `main.tf` in the section `IAM user`.
```
module "iam_user-XX" {
  source = "../../modules_AWS/terraform-aws-iam-master/modules/iam-user"
  name = "user-name"                    // your username
  force_destroy = true
  create_iam_user_login_profile = true  // generate login password
  pgp_key = "xxxxxxx"                   //public key to generate login password
  create_iam_access_key         = true  // generate API access key (useful for terraform provisioning)
}
```

To generate the `pgp_key` on your local machine do the following steps

### Install gnupg
macOS
```
brew install gnupg
```
Ubuntu
```
sudo apt install gnupg
```
### Generate an encryption key
```
gpg  --generate-key
```
### Export the public key
```
gpg --export <public-key-id> | base64
```
The `<public-key-id>` parameter can be found by listing all keys.
```
gpg --list-keys
```
