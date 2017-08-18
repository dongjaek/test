#!/bin/bash

# Allow root to sudo without tty
echo \Defaults:root !requiretty\ > /etc/sudoers.d/91-puppetdb
chmod 0440 /etc/sudoers.d/91-puppetdb

echo "Starting Passtiche Daemon to mount secrets"
nohup /usr/bin/passtiched --config-file=/etc/passtiche/config.yaml > /tmp/passtiched.log 2>&1&  # noqa
echo $! 1> /tmp/passtiched.pid
sleep 20  # Since we nohuped passtiched we need to give it some time to come up

echo "Copying SSL certs to local filesystem from mount"
sudo -u puppet mkdir -p /etc/puppetlabs/puppetdb/ssl
sudo -u puppet mkdir -p /etc/puppetlabs/puppetdb/conf.d
chown -R puppetdb:puppetdb /etc/puppetlabs/puppetdb/ssl
chown -R puppetdb:puppetdb /etc/puppetlabs/puppetdb/conf.d
sudo -u puppet cp /etc/twkeys/puppetdb/ssl/ca.pem /etc/puppetlabs/puppetdb/ssl/ca.pem
sudo -u puppet cp /etc/twkeys/puppetdb/ssl/public.pem /etc/puppetlabs/puppetdb/ssl/public.pem
sudo -u puppet cp /etc/twkeys/puppetdb/ssl/private.pem /etc/puppetlabs/puppetdb/ssl/private.pem
sudo -u puppet chmod 0644 /etc/puppetlabs/puppetdb/ssl/ca.pem
sudo -u puppet chmod 0644 /etc/puppetlabs/puppetdb/ssl/public.pem
sudo -u puppet chmod 0600 /etc/puppetlabs/puppetdb/ssl/private.pem
sudo -u puppet chmod 0600 /etc/puppetlabs/puppetdb/conf.d/database.ini
chown -R puppetdb:puppetdb /etc/puppetlabs/puppetdb/ssl
chown -R puppetdb:puppetdb /etc/puppetlabs/puppetdb/conf.d

echo "Configuring puppetdb config file"
# https://cloud.google.com/community/tutorials/setting-up-postgres#open-the-network-port
CONN_STRING="db.puppet.guc1.pcs.io:5432/puppet"
sed -i -e 's/$CONNECTION_STRING/$CONN_STRING/g' /etc/puppetlabs/puppetdb/conf.d/database.ini
SQL_PASSWORD=$(sudo -u puppetdb cat /etc/twkeys/puppetdb/sql_password)
sed -i -e 's/$PASSWORD/$SQL_PASSWORD/g' /etc/puppetlabs/puppetdb/conf.d/database.ini

echo "Killing Passtiche Daemon and unmounting secrets mount"
kill `cat /tmp/passtiched.pid`
cat /tmp/passtiched.pid
rm /tmp/passtiched.pid
