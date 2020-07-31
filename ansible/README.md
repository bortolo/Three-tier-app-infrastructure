## HOW TO LAUNCH THESE PLAYBOOKS

From `/ansible` folder...

After a terraform apply run always (update the path of your ansible vault password and auzre credentials file):
`ansible-playbook --vault-id /Users/andreabortolossi/ansible_vault_password -i ./myazure_rm.yml ./onboard_private_server/onboardservers.yml -l tag_environment_management`

If you want to update the monitoring setup run:
`ansible-playbook -i ./myazure_rm.yml ./setup_monitoring/setup-prometheus.yml -l tag_environment_management`

If you want to deploy the application packages run:
`ansible-playbook -i ./myazure_rm.yml ./deployments/deploy-manually.yml -l tag_environment_management`
