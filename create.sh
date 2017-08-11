#!/bin/bash

echo "Setting up provider symlinks to fill in variables"
# ln -sf $(pwd)/provider.tf $(pwd)/dns_zone/provider.tf
# ln -sf $(pwd)/provider.tf $(pwd)/zookeeper/provider.tf
# ln -sf $(pwd)/provider.tf $(pwd)/mesos/provider.tf

run_terraform () {
  terraform get $1
  terraform plan $1 
  terraform apply $1
}

echo "Creating the environment"
# run_terraform dns_zone
# run_terraform zookeeper
# run_terraform mesos
