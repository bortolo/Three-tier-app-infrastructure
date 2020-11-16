#!/bin/sh
echo "Setting db credentials"
export TF_VAR_db_username="user"
export TF_VAR_db_password="YourPwdShouldBeLongAndSecure!"
export TF_VAR_db_private_dns="database.example.com"
export TF_VAR_db_secret_name="db-secret-14"
