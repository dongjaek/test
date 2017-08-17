#!/bin/bash

# Allow root to sudo without tty
echo \Defaults:root !requiretty\ > /etc/sudoers.d/91-puppetdb
chmod 0440 /etc/sudoers.d/91-puppetdb

# Run passtiched
echo "Starting Passtiche Daemon to mount secrets"
nohup /usr/bin/passtiched --config-file=/etc/passtiche/config.yaml > /tmp/passtiched.log 2>&1&  # noqa
echo $! 1> /tmp/passtiched.pid
sleep 20  # Since we nohuped passtiched we need to give it some time to come up

# Put SSL certs into place
echo "Copying SSL certs to local filesystem from mount"
mkdir -p /etc/puppetlabs/puppetdb/ssl
mkdir -p /etc/puppetlabs/puppetdb/conf.d

cp /etc/twkeys/puppetdb/ssl/ca.pem /etc/puppetlabs/puppetdb/ssl/ca.pem
cp /etc/twkeys/puppetdb/ssl/public.pem /etc/puppetlabs/puppetdb/ssl/public.pem
cp /etc/twkeys/puppetdb/ssl/private.pem /etc/puppetlabs/puppetdb/ssl/private.pem
chmod 0644 /etc/puppetlabs/puppetdb/ssl/ca.pem
chmod 0644 /etc/puppetlabs/puppetdb/ssl/public.pem
chmod 0600 /etc/puppetlabs/puppetdb/ssl/private.pem
chmod 0600 /etc/puppetlabs/puppetdb/conf.d/database.ini
chown -R puppetdb:puppetdb /etc/puppetlabs/puppetdb/ssl
chown -R puppetdb:puppetdb /etc/puppetlabs/puppetdb/conf.d

# Stop passtiched
echo "Killing Passtiche Daemon and unmounting secrets mount"
kill `cat /tmp/passtiched.pid`
rm /tmp/passtiched.pid
umount /etc/twkeys/
