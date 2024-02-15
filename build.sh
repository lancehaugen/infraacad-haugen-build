#!/bin/bash
# Description: Build script to validate and build aws resources via terraform
# USAGE: ./build.sh

arg_count="$#"
current_dir=`pwd`

function logMessage(){
    echo -e "\n"
    header=`echo $1 | tr [a-z] [A-Z]`
    echo -e "******* $header *******\n"
}

function displayUsage(){
    echo -e "USAGE: ./build.sh [environment_tfvars_name]\n"
    exit 1
}

function validateArgs(){
    if [ $arg_count -eq 0 ]
    then
        logMessage "USAGE Error"
        echo "ERROR: At least 1 args is required."
        displayUsage
    fi
}

function unsetProxy(){
    unset HTTP_PROXY
    unset HTTPS_PROXY
    unset NO_PROXY
}


#validateArgs

logMessage "Disabling Proxy"
unsetProxy

logMessage "Initializing Terraform"
terraform init

logMessage "Formatting terraform"
terraform fmt -diff

logMessage "Validating Terraform"
validate_output=`terraform validate`
validate_success=`echo $validate_output | grep Success`

echo $validate_output

# If Validate Success then continue
if [[ $validate_success =~ "Success" ]]; then

    logMessage "Running Terraform Plan"
    terraform apply
else
    echo -e "Fix errors and run ./build.sh again.\n"
fi 

echo -e "\n"