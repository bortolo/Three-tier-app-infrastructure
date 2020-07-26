[INTRODUCTION]

Deploy a three-tier-app (currently just web and app layer) using packer templates, terraform provisioning techniques and ansible playbooks.

[PACKER]

Use this tool to create template images in your Azure account for the servers you are going to deploy.

CONFIGURE
- Enable AZURE credentials before launch terraform commands
  export ARM_SUBSCRIPTION_ID=XXXXXXX
  export ARM_CLIENT_ID=XXXXXXX
  export ARM_CLIENT_SECRET=XXXXXXX
  export ARM_TENANT_ID=XXXXXXX
  
RUN
- run "packer build template_name.json" from ./packer_templates

[TERRAFORM]

Use this tool to deploy all the infrastructure resources your application need (network, servers, storage ...)

CONFIGURE
- Enable AZURE credentials before launch terraform commands
  export ARM_SUBSCRIPTION_ID=XXXXXXX
  export ARM_CLIENT_ID=XXXXXXX
  export ARM_CLIENT_SECRET=XXXXXXX
  export ARM_TENANT_ID=XXXXXXX
- Configure tags (jumphost=tag_environment_management, web=tag_environment_web, app=tag_environment_app). Please take care about tag choice. Right now the code is not fully automated. See the onboard-servers.sh file to see what is missing to fully automate it.

RUN:
- run "terraform apply" from ./terraform_main folder
- run "terraform destroy" to shut down everything you just created

[ANSIBLE]
Use this tool to configure all the infrastructure resources deployed with terraform.
Install all the useful packages, download the gitrepos and start the app services.

CONFIGURE
- name of the AZURE resource group on which run dynamic inventory (myazure_rm.yml)
- name of the user (we are assuming that all the hosts have one user defined with that name)
- name of the gitrepos (in this example web is based on node.js app and app is based on .war file)
- Configure tags (jumphost=tag_environment_management, web=tag_environment_web, app=tag_environment_app)

NOTE: the last point is highly dependent on terraform provisioning and it is not yet completely dynamic.

SECURITY:
- Create a password file (don't upload this file on a gitrepo)
  echo "mypassword" > password_file
- Change the credential file with your azure credential file and encrypt it
  ansible-vault encrypt --vault-id [path_to_the_file_with_your_password] credentials
- Update the password used by the ansible user to logon on private servers (we are using a symetric approach for private comunication)
  ansible-vault encrypt_string --vault-id [path_to_the_file_with_your_password] [your_server_password]
- Insert the vault string just created in the deploy-master.yml file in the variable "server_password"

NOTE: Azure credential file has the following structure:
[default]
subscription_id=XXXXXXX
client_id=XXXXXXX
secret=XXXXXXX
tenant=XXXXXXX

RUN:
ansible-playbook --vault-id [path_to_the_file_with_your_password] -i ./myazure_rm.yml deploy-master.yml -l [jumphost_azure_tag]
