#!/bin/bash
      
# start puppetdb and puppet
/opt/puppetlabs/bin/puppet resource service puppetdb ensure=running enable=true
/opt/puppetlabs/bin/puppet agent --test
systemctl enable puppet.service
systemctl start puppet.service
