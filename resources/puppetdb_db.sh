#!/bin/bash

# TODO clearly broken, need to fix this with the magic of dns 
conn_string = Join('', ["//", Ref(local_dns), ":", sql_port, "/puppet"])
"sed -i s\|'$CONNECTION_STRING'\|'", conn_string, "'\|g /etc/puppetlabs/puppetdb/conf.d/database.ini"

# REPLACE 
# replacecmd
/etc/puppetlabs/puppetdb/conf.d/database.ini',
          "'$PASSWORD'",
sudo -u puppetdb cat /etc/twkeys/puppetdb/sql_password
