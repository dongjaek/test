#!/bin/bash

      # Configure Passtiche
      ReplaceCmd('/tmp/passtiche_config.yaml', "'$REGION'", self.config.Region),
      # Allow root to sudo without tty
      RunCmd('echo \'Defaults:root !requiretty\' > /etc/sudoers.d/91-puppetdb'),
      RunCmd('chmod', '0440', '/etc/sudoers.d/91-puppetdb'),
      # Run pastiched
      RunCmd('nohup /usr/bin/passtiched --config-file=/tmp/passtiche_config.yaml > /tmp/passtiched.log 2>&1&'),  # noqa
      RunCmd('echo $! 1> /tmp/passtiched.pid'),
      RunCmd('sleep', '20'),  # Since we nohuped passtiched we need to give it some time to come up
      # Put SSL certs into place
      RunCmd('mkdir', '-p', '/etc/puppetlabs/puppetdb/ssl'),
      RunCmd('chown', 'puppetdb:puppetdb', '/etc/puppetlabs/puppetdb/ssl'),
      RunCmd(
          'sudo',
          '-u',
          'puppetdb',
          'cp',
          '/etc/twkeys/puppetdb/ssl/ca.pem',
          '/etc/puppetlabs/puppetdb/ssl/ca.pem'),
      RunCmd(
          'sudo',
          '-u',
          'puppetdb',
          'cp',
          '/etc/twkeys/puppetdb/ssl/public.pem',
          '/etc/puppetlabs/puppetdb/ssl/public.pem'),
      RunCmd(
          'sudo',
          '-u',
          'puppetdb',
          'cp',
          '/etc/twkeys/puppetdb/ssl/private.pem',
          '/etc/puppetlabs/puppetdb/ssl/private.pem'),
      RunCmd('chmod', '0644', '/etc/puppetlabs/puppetdb/ssl/ca.pem'),
      RunCmd('chmod', '0644', '/etc/puppetlabs/puppetdb/ssl/public.pem'),
      RunCmd('chmod', '0600', '/etc/puppetlabs/puppetdb/ssl/private.pem'),

      RunCmd('chown', '-R', 'puppetdb:puppetdb', '/etc/puppetlabs/puppetdb/conf.d'),
      RunCmd('chmod', '0600', '/etc/puppetlabs/puppetdb/conf.d/database.ini'),
      # Stop passtiched
      RunCmd('kill `cat /tmp/passtiched.pid`'),
      RunCmd('umount /etc/twkeys/'),
