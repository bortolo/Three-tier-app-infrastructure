#!/bin/bash
# Create a static inventory of IPs from myazure_rm.yml dynamic inventory
# JSON file created by myazure_rm.yml is parsed with jq
# server.txt is created appending all IPs with the tag tag_environment_app and tag_environment_web
# server.txt is used by the script onboardVMs.sh to create the ssh tunnel between ansible server and the other servers
#
# TO DO:
# The password for the hosts should be passed as parameter.

PASSWORD=$1

rm -f server.txt
rm -f azure_resource_list.json

# Print the dynamic inventory on a json file
# TODO Work with this file to enable dynamic tag choice for different groups of servers
ansible-inventory -i myazure_rm.yml --list > azure_resource_list.json

# Append all IP of the host with tag_environment_app
LENGTH=$(ansible-inventory -i myazure_rm.yml --list | jq '.tag_environment_app.hosts | length')
for (( i=0 ; i < $LENGTH ; i++ ));
do
  temp=$(ansible-inventory -i myazure_rm.yml --list | jq .tag_environment_app.hosts[$i])
  temp="${temp%\"}"
  temp="${temp#\"}"
  temp=$(ansible-inventory -i myazure_rm.yml --list | jq ._meta.hostvars.$temp.ansible_host)
  temp="${temp%\"}"
  temp="${temp#\"}"
  echo $temp >> server.txt
done

# Append all IP of the host with tag_environment_web
LENGTH=$(ansible-inventory -i myazure_rm.yml --list | jq '.tag_environment_web.hosts | length')
for (( i=0 ; i < $LENGTH ; i++ ));
do
  temp=$(ansible-inventory -i myazure_rm.yml --list | jq .tag_environment_web.hosts[$i])
  temp="${temp%\"}"
  temp="${temp#\"}"
  temp=$(ansible-inventory -i myazure_rm.yml --list | jq ._meta.hostvars.$temp.ansible_host)
  temp="${temp%\"}"
  temp="${temp#\"}"
  echo $temp >> server.txt
done

# Clean all known_hosts
rm ~/.ssh/known_hosts

# Crate ssh tunnel with all the host in the list server.txt
for server in `cat server.txt`;
do
    ssh-keyscan -H $server >> ~/.ssh/known_hosts
    sshpass -p $PASSWORD ssh-copy-id -i ~/.ssh/id_rsa.pub myadmin@$server
done
