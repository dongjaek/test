#!/usr/bin/python

"""
The script is run as startup script on boot and allows us to keep the templates self contained.
https://cloud.google.com/deployment-manager/docs/step-by-step-guide/setting-metadata-and-startup-scripts
"""

import json
import logging
import socket
import subprocess
import os
import urllib2
import pwd
import grp


LOG = logging.getLogger()
# https://cloud.google.com/compute/docs/storing-retrieving-metadata
METADATA_ROOT = 'http://metadata.google.internal/computeMetadata/v1/instance'

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
      req = urllib2.Request(url, headers={'Metadata-Flavor': 'Google'})
      r = urllib2.urlopen(req).read()
      LOG.info('found: {}'.format(url))
      return r
    except Exception as e:
      LOG.error('failed: {}, retrying, count: {}, msg: {}'.format(url, retries, str(e)))
      retries += 1
      if retries > 3:
	return ''


@memoized
def custom_metadata(key):
  query = '%s/%s/%s' % (METADATA_ROOT, 'attributes', key)
  metadata = get(query)
  if not metadata:
    LOG.error("Could not find {}".format(query))
  return metadata


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


def _write_file(filename, blob):
  with open(filename, "w") as f:
    f.write(blob)

def _run_script(script):
  script_name = '-'.join(['script', script])
  script_blob = custom_metadata(script_name)
  script_filename = script + '.sh'
  LOG.info('Writing {}'.format(script_filename))
  with open(script_filename, "w") as f:
    f.write(script_blob)
    os.chmod(script_filename, 0o775)
  subprocess.call(''.join(['./', script_filename]))


def main():
  _set_nameserver()
  _set_fqdn()
  _write_facts()
  _write_puppet_config()
  _write_autosign_conf()
  _run_script('puppetmaster_dns')
  _run_script('puppetmaster_passtiche')
  _run_script('puppetmaster_init')


def _set_nameserver():
  nameserver = custom_metadata('dhcp_nameserver') or '10.249.64.2'
  with open('/etc/resolv.conf', 'w') as f:
    f.write('nameserver %s' % nameserver)


def _set_fqdn():
  ip_addr = private_ip()
  # TODO update to getnameinfo later?
  if ip_addr:
    host_info = socket.gethostbyaddr(ip_addr)
    hostname = host_info[0]
    shell(['/bin/hostname', '-b', hostname])
  else:
    LOG.error('Cannot access private_ip')


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


AUTOSIGN = "*.{}.{}".format(tw_region(), tw_tld())

PUPPET_TEMPLATE = """[main]
certname = {certname}
server = {server}
environment = {environment}
runinterval = 20m
certificate_revocation = false

[master]
certname = {certname}
autosign = /etc/puppetlabs/puppet/autosign.conf
"""


def _write_autosign_conf():
  filename = "/etc/puppetlabs/puppet/autosign.conf"
  LOG.info('Writting autosign configuration: {}'.format(filename))
  with open(filename, "w") as autosign:
    autosign.write(AUTOSIGN)
    uid = pwd.getpwnam("puppet").pw_uid
    gid = grp.getgrnam("puppet").gr_gid
    os.chown(filename, uid, gid)
    os.chmod(script_filename, 0o770)


def _write_puppet_config():
  hostname = socket.getfqdn()
  server = 'puppet.%s.%s' % (tw_region(), tw_tld())
  certname = server
  puppet_config = PUPPET_TEMPLATE.format(
    certname=certname,
    server=server,
    environment=custom_metadata('puppet_environment')
  )
  with open('/etc/puppetlabs/puppet/puppet.conf', 'w') as f:
    f.write(puppet_config)


if __name__ == '__main__':
  logging.basicConfig(level='INFO')
  main()
