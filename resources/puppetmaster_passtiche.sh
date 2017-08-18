#!/bin/bash

# start passtiche and save the pid so we can kill it later
echo "Starting Passtiche Daemon to mount secrets"
nohup /usr/bin/passtiched --config-file=/etc/passtiche/config.yaml > /tmp/passtiched.log 2>&1&
echo $! 1> /tmp/passtiched.pid
echo "Passtiched PID: $(cat /tmp/passtiched.pid)"
sleep 20 # since we nohuped passtiched we need to give it some time to come up

as_p () {
  echo "$1"
  sudo -u puppet bash -c "$($1)"
}

# Setup ssh keys for git
echo "Copying github secrets to local filesystem from mount"
mkdir -p /opt/puppetlabs/server/data/puppetserver/.ssh
as_p "cp /etc/twkeys/puppetmaster/git/id_rsa /opt/puppetlabs/server/data/puppetserver/.ssh/id_rsa"
as_p "cp /etc/twkeys/puppetmaster/git/id_rsa.pub /opt/puppetlabs/server/data/puppetserver/.ssh/id_rsa.pub"
chmod 0600 /opt/puppetlabs/server/data/puppetserver/.ssh/id_rsa
chmod 0644 /opt/puppetlabs/server/data/puppetserver/.ssh/id_rsa.pub
as_p "ssh-keyscan github.com >> /opt/puppetlabs/server/data/puppetserver/.ssh/known_hosts"
chown -R puppet:puppet /opt/puppetlabs/server/data/puppetserver/.ssh

# Setup certificate authority
echo "Copying CA secrets to local filesystem from mount"
rm -rf /etc/puppetlabs/puppet/ssl
mkdir -p /etc/puppetlabs/puppet/ssl/ca
touch /etc/puppetlabs/puppet/ssl/ca/inventory.txt
as_p "cp /etc/twkeys/puppetmaster/ca/* /etc/puppetlabs/puppet/ssl/ca/."
chmod 0644 /etc/puppetlabs/puppet/ssl/ca/*
chmod 0640 /etc/puppetlabs/puppet/ssl/ca/ca_key.pem
chown -R puppet:puppet /etc/puppetlabs/puppet/ssl

# Stop passtiched
echo "Killing Passtiche Daemon and unmounting secrets mount"
kill `cat /tmp/passtiched.pid`
rm /tmp/passtiched.pid
umount /etc/twkeys/