#!/bin/bash
# variables are duplicated in remote/provider.tf because terraform interpolation is non-existent
REGION="us-east-1"
BUCKET_NAME="pcs_state_bucket"
TABLE_NAME="pcs_state_lock"
DB_PASSWORD=
ACCESS_KEY=
SECRET_ACCESS_KEY=

echo "Setting up remote state backend"
cd remote
echo "yes" | terraform init
terraform plan
terraform apply
cd -

# echo "Setting terraboard to run at localhost:8080"
# TODO put this on elastic beanstalk as a multi-container setup
# TODO migrate to an RDS VPC instance
# docker run -d -p 8080:8080 \
#    -e AWS_REGION=${REGION} \
#    -e AWS_ACCESS_KEY_ID=${ACCESS_KEY} \
#    -e AWS_SECRET_ACCESS_KEY=${SECRET_ACCESS_KEY} \
#    -e AWS_BUCKET=${BUCKET_NAME} \
#    -e AWS_DYNAMODB_TABLE=${TABLE_NAME} \
#    -e DB_PASSWORD=${DB_PASSWORD} \
#    --link postgres:db \
#    camptocamp/terraboard:latest

echo "Setting up the main work directory"
terraform init

echo "Removing the remote bootstrap state files"
terraform state push -force remote/terraform.tfstate
rm remote/terraform.tfstate*
rm -rf remote/.terraform
