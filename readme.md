
aws cloudformation validate-template --template-body file://home-automation-infra-pipeline.yml



aws cloudformation create-stack --stack-name ha-dev-infra --template-body file://home-automation-infra-pipeline.yml  --region ap-south-1 --profile saml --capabilities CAPABILITY_NAMED_IAM


aws cloudformation update-stack --stack-name ha-dev-infra --template-body file://home-automation-infra-pipeline.yml  --region ap-south-1 --profile saml --capabilities CAPABILITY_NAMED_IAM