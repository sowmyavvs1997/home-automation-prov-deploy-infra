#!/bin/bash

export REGION="ap-south-1"

echo "Pipeline is all set to rack n roll terraform ... :-)"

git config --global credential.helper'store --file .git-credentials'

echo "AWS Version is : $(aws --version)"

pip install --upgrade awscli

echo "AWS version post upgrade : $(aws --version)"

CC_USER=`aws ssm get-parameters --region $REGION --with-decryption --names codecommit_username | jq -r '.Parameters| .[]|  .Value'`
CC_PASSWORD=`aws ssm get-parameters --region $REGION --with-decryption --names codecommit_password | jq -r '.Parameters| .[]|  .Value'`
sed -i -e "s/CC_USER/${CC_USER}/g" .git-credentials
sed -i -e "s/CC_PASSWORD/${CC_PASSWORD}/g" .git-credentials

#COMMAND=$1
#ENV=$2

#if [ -z "$COMMAND" ] || [ -z "$ENV" ]; then
 # echo "Usage: ./run.sh <command> <environment>"
 # exit 1
#fi

#cd ../environments/$ENV
#terraform $COMMAND

terraform init

echo "executing terraform plan"
terraform plan -lock=false
echo "Done. terraform plan"

#echo "executing terraform apply"
#terraform apply -auto-approve
#echo "Done. terraform apply"

#echo "executing terraform destroy"
#terraform destroy -force
#echo "Done. terraform destroy"