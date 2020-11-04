#!/bin/bash
# Set-up DNS server using bind9 see https://badshah.io/how-i-hosted-a-dns-server-on-aws/

# Setup log rotation

tee /etc/logrotate.d/bind << EOF
/var/log/named/bind.log
{
    rotate 90
    daily
    dateext
    dateformat _%Y-%m-%d
    missingok
    create 644 bind bind
    delaycompress
    compress
    notifempty
    postrotate
        /bin/systemctl reload bind9
    endscript
}
EOF

# Change the zone to your domain name

tee /etc/bind/named.conf.local << EOF
zone "awstestdomain.cf" {
        type master;
        file "/etc/bind/zones/db.awstestdomain.cf";
};
EOF

mkdir /etc/bind/zones

# Creating the zone files
# Setting AWS elastic IP

ElasticIP=18.158.247.254

# Please dont forget . at the end of the DNS entries

tee /etc/bind/zones/db.awstestdomain.cf << EOF
\$TTL 900
@       IN      SOA     ns1.awstestdomain.cf. admin.awstestdomain.cf. (
                                1       ;<serial-number>
                              900       ;<time-to-refresh>
                              900       ;<time-to-retry>
                           604800       ;<time-to-expire>
                              900)      ;<minimum-TTL>
;List Nameservers
        IN      NS      ns1.awstestdomain.cf.
        IN      NS      ns2.awstestdomain.cf.
;Create A record
        IN      A       127.0.0.1
;address to name mapping
ns1     IN      A       $ElasticIP
ns2     IN      A       $ElasticIP
;wildcard DNS entry
*       IN      A       127.0.0.1
EOF

#service bind9 restart
