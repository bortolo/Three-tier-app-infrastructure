#!/bin/sh
echo "Configure environment variable to run terraform apply"
export TF_VAR_db_username="user"
export TF_VAR_db_password="YourPwdShouldBeLongAndSecure!"
export TF_VAR_db_private_dns="database.example.com"
export TF_VAR_db_secret_name="db-secret-21"
export TF_VAR_iam_role_name="accessRDS"
export TF_VAR_key_pair_name="RDSappkey"
