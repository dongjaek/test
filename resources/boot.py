#!/usr/bin/python

"""
This script sets:
  DHCP nameserver
  FQDN
  facts from the metadata server
  generates a puppet config from metadata facts
  runs puppet to pull down catalogs

The script is run as startup script on boot and allows us to keep the templates self contained.
https://cloud.google.com/deployment-manager/docs/step-by-step-guide/setting-metadata-and-startup-scripts
"""

import json
import logging
import socket
import subprocess

import requests
from requests import ConnectionError
from requests import HTTPError


LOG = logging.getLogger()
# https://cloud.google.com/compute/docs/storing-retrieving-metadata
# essentially puppet facts and other stuff
METADATA_ROOT = 'http://169.254.169.254/computeMetadata/v1/instance/'

class memoized(object):
  UNSET = object()

  def __init__(self, fn):
    self._fn = fn
    self._cache = {}

  def __call__(self, *args, **kwargs):
    key = (args, tuple(sorted(kwargs.items())))
    value = self._cache.get(key, self.UNSET)
    if value is self.UNSET:
      value = self._fn(*args, **kwargs)
      self._cache[key] = value
    return value


def shell(cmd):
  subprocess.call(cmd)


def get(url):
  retries = 0
  while True:
    try:
      r = requests.get(url, headers={
        'Metadata-Flavor': 'Google'
      }, timeout=1)
      if r.status_code == 404:
        return None
      return r.text
    except (ConnectionError, HTTPError) as e:
      retries += 1
      if retries > 3:
        raise

@memoized
def custom_metadata(key):
  query = '%s/%s/%s' % (METADATA_ROOT, 'attributes/', key)
  metadata = get(query)
  if not metadata:
    LOG.error("Could not find {}".format(query))


@memoized
def private_ip():
  return get('%s/%s' % (METADATA_ROOT, 'network-interfaces/0/ip'))


def tw_region():
  return custom_metadata('tw_region')


def tw_tld():
  return custom_metadata('tw_tld')


def puppet_role():
  return custom_metadata('puppet_role')


def puppet_subrole():
  return custom_metadata('puppet_subrole')


def main():
  _set_nameserver()
  _set_fqdn()
  _write_facts()
  _write_puppet_config()
  _run_puppet()


def _set_nameserver():
  nameserver = custom_metadata('dhcp_nameserver') or '10.249.64.2'
  with open('/etc/resolv.conf', 'w') as f:
    f.write('nameserver %s' % nameserver)


def _set_fqdn():
  ip_addr = private_ip()
  # TODO update to getnameinfo later?
  host_info = socket.gethostbyaddr(ip_addr)
  hostname = host_info[0]
  shell(['/bin/hostname', '-b', hostname])


def _write_facts():
  extra_facts = custom_metadata('puppet_extra_facts')
  if extra_facts:
    extra_facts = json.loads(extra_facts)

  fact_dct = {
    'puppet_role': puppet_role(),
    'puppet_subrole': puppet_subrole()
  }
  fact_dct.update(extra_facts or {})
  with open('/opt/puppetlabs/facter/facts.d/pcs_facts.yaml', 'w') as f:
    json.dump(fact_dct, f)


PUPPET_TEMPLATE = """[main]
certname = {certname}
server = {server}
environment = {environment}
runinterval = 20m
certificate_revocation = false
"""


def _write_puppet_config():
  hostname = socket.getfqdn()
  puppet_config = PUPPET_TEMPLATE.format(
    certname='%s.%s.%s' % (puppet_role(), puppet_subrole(), hostname),
    server='puppet.%s.%s' % (tw_region(), tw_tld()),
    environment=custom_metadata('puppet_environment')
  )
  with open('/etc/puppetlabs/puppet/puppet.conf', 'w') as f:
    f.write(puppet_config)


def _run_puppet():
  shell(['/bin/systemctl', 'start', 'puppet.service'])


if __name__ == '__main__':
  logging.basicConfig(level='INFO')
  main()
