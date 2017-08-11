#!/bin/bash

echo "Setting up remote state backend"
cd remote
echo "yes" | terraform init
terraform plan
terraform apply
cd -

echo "Setting up the main work directory"
terraform init

echo "Removing the remote bootstrap state files"
terraform state push -force remote/terraform.tfstate
rm remote/terraform.tfstate*
rm -rf remote/.terraform
