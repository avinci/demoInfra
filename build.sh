#!/bin/bash -e

export TF_INSALL_LOCATION=/opt
export TF_VERSION=0.6.9
export REPO_RESOURCE_NAME="demo-infra-repo"
export RES_AWS_CREDS="aws-demo-creds"
export RES_AWS_PEM="aws-demo-pem"
export RES_PARAMS="infra-params"

install_terraform() {
  pushd $TF_INSALL_LOCATION
  echo "Fetching terraform"
  echo "-----------------------------------"

  rm -rf $TF_INSALL_LOCATION/terraform
  mkdir -p $TF_INSALL_LOCATION/terraform

  wget -q https://releases.hashicorp.com/terraform/$TF_VERSION/terraform_"$TF_VERSION"_linux_386.zip
  apt-get install unzip
  unzip -o terraform_"$TF_VERSION"_linux_386.zip -d $TF_INSALL_LOCATION/terraform
  export PATH=$PATH:$TF_INSALL_LOCATION/terraform
  echo "downloaded terraform successfully"
  echo "-----------------------------------"
  
  local tf_version=$(terraform version)
  echo "Terraform version: $tf_version"
  popd
}

get_params() {
  echo "Set PARAM from" $RES_PARAMS
  pushd /build/IN/$RES_PARAMS
  cat version.json | jq '.version.propertyBag.params' | jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" > params.txt
  . params.txt
  popd
  echo "Completed Set PARAM from" $RES_MICRO_IMAGE
}

get_statefile() {
  echo "Copying previous state file"
  echo "-----------------------------------"
  local previous_statefile_location="/build/previousState/terraform.tfstate"
  if [ -f "$previous_statefile_location" ]; then
    echo "statefile exists, copying"
    echo "-----------------------------------"
    cp -vr previousState/terraform.tfstate /build/IN/$REPO_RESOURCE_NAME/gitRepo
  else
    echo "no previous statefile exists"
    echo "-----------------------------------"
  fi
}

create_pemfile() {
 echo "Extracting AWS PEM"
 echo "-----------------------------------"
 cat ./IN/$RES_AWS_PEM/integration.json  | jq -r '.key' > ./IN/$REPO_RESOURCE_NAME/gitRepo/demo-key.pem
 chmod 600 ./IN/$REPO_RESOURCE_NAME/gitRepo/demo-key.pem
 echo "Completed Extracting AWS PEM"
 echo "-----------------------------------"
}

destroy_changes() {
  pushd /build/IN/$REPO_RESOURCE_NAME/gitRepo
  echo "-----------------------------------"

  echo "destroy changes"
  echo "-----------------------------------"
  terraform destroy -force -var-file=/build/IN/$RES_AWS_CREDS/integration.env
  popd
}

apply_changes() {
  pushd /build/IN/$REPO_RESOURCE_NAME/gitRepo
  echo "-----------------------------------"
  ps -eaf | grep ssh
  ls -al ~/.ssh/
  which ssh-agent

  echo "planning changes"
  echo "-----------------------------------"
  terraform plan -var-file=/build/IN/$RES_AWS_CREDS/integration.env
  echo "apply changes"
  echo "-----------------------------------"
  terraform apply -var-file=/build/IN/$RES_AWS_CREDS/integration.env
  popd
}

main() {
  eval `ssh-agent -s`
  get_params
  install_terraform
  get_statefile
  create_pemfile

  if [ $INFRA_ACTION=="destroy" ]; then
    echo "DESTROYING INFRA"
    echo "-----------------------------------"
    destroy_changes
  fi

  if [ $INFRA_ACTION=="provision" ]; then
    echo "PROVISIONING INFRA"
    echo "-----------------------------------"
    apply_changes
  fi
}

main

