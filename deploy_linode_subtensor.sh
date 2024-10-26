#!/bin/bash

cd "$(dirname "$0")"

# Check if terraform is installed, if it is not, print a link to installation instructions and exit
if ! command -v terraform &> /dev/null
then
    echo "Terraform could not be found"
    echo "Please follow the installation instructions at https://learn.hashicorp.com/tutorials/terraform/install-cli"
    exit 1
fi

# Check if venv exists, if it doesn't, create it
if [ ! -d "../bt-subtensor-tools-venv" ]
then
    echo "Creating virtual environment..."
    python3 -m venv ../bt-subtensor-tools-venv
fi

# Activate venv and install requirements.txt
source ../bt-subtensor-tools-venv/bin/activate
pip install -r requirements.txt

# Check if infra/.envrc exists, if not, create from example and substitute API token
if [ ! -f "infra/.envrc" ]
then
    read -p 'Linode API Token: ' apiToken
    echo "infra/.envrc not found, creating..."
    sed "s/export LINODE_TOKEN=.*/export LINODE_TOKEN=$apiToken/" infra/.envrc.example > infra/.envrc
fi

# Check if terraform.tfvars exists, if not, create from example and substitute SSH key
if [ ! -f "infra/terraform.tfvars" ]
then
    read -p 'SSH key: ' sshKey
    echo "infra/terraform.tfvars not found, creating..."
    sed "s/SSH_KEY_HERE/$sshKey/" infra/terraform.tfvars.example > infra/terraform.tfvars
fi

cd infra
source .envrc
terraform init
terraform apply