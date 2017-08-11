#!/bin/bash


# https://github.com/camptocamp/terraboard

# set these with an export beforehand!
# ACCESS_KEY=
# SECRET_ACCESS_KEY=
# DB_PASSWORD=

docker run -d -p 8080:8080 \
   -e AWS_REGION=${TF_VAR_REGION} \
   -e AWS_ACCESS_KEY_ID=${ACCESS_KEY} \
   -e AWS_SECRET_ACCESS_KEY=${SECRET_ACCESS_KEY} \
   -e AWS_BUCKET=${TF_VAR_bucket_name} \
   -e AWS_DYNAMODB_TABLE=${TF_VAR_lock_table} \
   -e DB_PASSWORD=${DB_PASSWORD} \
   --link postgres:db \
   camptocamp/terraboard:latest

echo "Unsetting secrets"
unset ACCESS_KEY
unset SECRET_ACCESS_KEY
unset DB_PASSWORD
