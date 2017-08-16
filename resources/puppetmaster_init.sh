#!/bin/bash

# Start Puppet master services
systemctl enable r10k.timer
systemctl start r10k.timer
systemctl enable puppetserver.service
systemctl start puppetserver.service
# Run puppet agent and start service
/opt/puppetlabs/bin/puppet agent --test
systemctl enable puppet.service
systemctl start puppet.service
