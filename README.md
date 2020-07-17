IMPORTANT TO CONFIGURE:
- Enable AZURE credentials before launch terraform commands
- Configure tags (jumphost=tag_environment_management, web=tag_environment_web, app=tag_environment_app)
- Set path_for_azure_credentials variable with your credentials in "setup-jumphostserver-dynamic.yml"
- name of the user on jumphost server in "setup-jumphostserver-dynamic.yml"
- name of the script to connect private VLAN servers in "setup-jumphostserver-dynamic.yml"
- name of the gitrepo for jumphost ansibleplaybooks in "setup-jumphostserver-dynamic.yml"

HOW TO RUN:
- run "terraform apply" from ./terraform_main folder
- run "ansible-playbook -i myazure_rm.yml setup-jumphostserver-dynamic.yml -l tag_environment_management" from ./ansible-playbooks folder

HOW TO CHANGE TEMPLATES:
- run "packer build template_name.json" from ./packer_templates


Other useful links
https://ubuntu.com/tutorials/install-and-configure-apache#1-overview
https://openclassrooms.com/en/courses/2504541-ultra-fast-applications-using-node-js/2504972-creating-your-first-app-with-node-js
https://www.digitalocean.com/community/tutorials/how-to-install-apache-tomcat-8-on-ubuntu-16-04
