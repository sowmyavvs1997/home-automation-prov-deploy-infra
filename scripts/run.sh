#!/bin/bash

COMMAND=$1
ENV=$2

if [ -z "$COMMAND" ] || [ -z "$ENV" ]; then
  echo "Usage: ./run.sh <command> <environment>"
  exit 1
fi

cd ../environments/$ENV
terraform $COMMAND