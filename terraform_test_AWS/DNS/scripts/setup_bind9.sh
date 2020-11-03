#!/bin/bash
# Set-up bind9 see https://badshah.io/how-i-hosted-a-dns-server-on-aws/

#apt install bind9 bind9-doc -y

echo 'include "/etc/bind/named.conf.log";' | tee -a /etc/bind/named.conf

# Store all the logs to /var/log/named/bind.log

tee /etc/bind/named.conf.log << EOF
logging {
 channel bind_log {
   file "/var/log/named/bind.log" versions 3 size 5m;
   severity info;
   print-category yes;
   print-severity yes;
   print-time yes;
 };
 category default { bind_log; };
 category update { bind_log; };
 category update-security { bind_log; };
 category security { bind_log; };
 category queries { bind_log; };
 category lame-servers { null; };
};
EOF

# Create the directory for storing logs

mkdir /var/log/named
chown bind:root /var/log/named
chmod 775 /var/log/named/
