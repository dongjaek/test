#!/bin/bash

destroy () {
  echo "in $1"
  cd $1
  rm -f terraform.tfstate
  rm -f terraform.tfstate.backup
  rm -rf .terraform
  cd -
}

echo "Destroying any infrastructure left over"
destroy dns_zone
destroy zookeeper 
destroy mesos 
destroy remote
destroy ./

# echo "yes" | terraform destroy -force
