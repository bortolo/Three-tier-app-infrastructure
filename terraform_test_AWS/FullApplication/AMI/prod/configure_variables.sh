#!/bin/sh
echo "Configure terraform variables for AMI(prod)"
export TF_VAR_AMI_name="RDSapp_0_1"
export TF_VAR_db_secret_name="db-secret-22"
export TF_VAR_iam_role_name="accessRDS"
export TF_VAR_key_pair_name="RDSappkey"
