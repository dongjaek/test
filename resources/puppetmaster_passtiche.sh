#!/bin/bash

# start passtiche and save the pid so we can kill it later
echo "Starting Passtiche Daemon to mount secrets"
nohup /usr/bin/passtiched --config-file=/etc/passtiche/config.yaml > /tmp/passtiched.log 2>&1&
echo $! 1> /tmp/passtiched.pid
echo "Passtiched PID: $(cat /tmp/passtiched.pid)"
sleep 120 # since we nohuped passtiched we need to give it some time to come up

# Setup ssh keys for git
echo "Copying github secrets to local filesystem from mount"
sudo -u puppet mkdir -p /opt/puppetlabs/server/data/puppetserver/.ssh
chown -R puppet:puppet /opt/puppetlabs/server/data/puppetserver/.ssh
sudo -u puppet cp /etc/twkeys/puppetmaster/git/id_rsa /opt/puppetlabs/server/data/puppetserver/.ssh/id_rsa
sudo -u puppet cp /etc/twkeys/puppetmaster/git/id_rsa.pub /opt/puppetlabs/server/data/puppetserver/.ssh/id_rsa.pub
sudo -u puppet chmod 0600 /opt/puppetlabs/server/data/puppetserver/.ssh/id_rsa
sudo -u puppet chmod 0644 /opt/puppetlabs/server/data/puppetserver/.ssh/id_rsa.pub
sudo -u puppet ssh-keyscan github.com >> /opt/puppetlabs/server/data/puppetserver/.ssh/known_hosts
chown -R puppet:puppet /opt/puppetlabs/server/data/puppetserver/.ssh

# Setup certificate authority
echo "Copying CA secrets to local filesystem from mount"
rm -rf /etc/puppetlabs/puppet/ssl
sudo -u puppet mkdir -p /etc/puppetlabs/puppet/ssl/ca
sudo -u puppet chown -R puppet:puppet /etc/puppetlabs/puppet/ssl
sudo -u puppet touch /etc/puppetlabs/puppet/ssl/ca/inventory.txt
sudo -u puppet cp /etc/twkeys/puppetmaster/ca/* /etc/puppetlabs/puppet/ssl/ca/
sudo -u puppet chmod 0644 /etc/puppetlabs/puppet/ssl/ca/*
sudo -u puppet chmod 0640 /etc/puppetlabs/puppet/ssl/ca/ca_key.pem
chown -R puppet:puppet /etc/puppetlabs/puppet/ssl

# Stop passtiched
echo "Killing Passtiche Daemon and unmounting secrets mount"
cat /tmp/passtiched.pid
kill `cat /tmp/passtiched.pid`
rm /tmp/passtiched.pid
