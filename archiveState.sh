#!/bin/bash -e

export REPO_RESOURCE_NAME="demo-infra-repo"

arch_statefile() {
  echo "Copying new state file"
  echo "-----------------------------------"
  local state_loc=/build/IN/$REPO_RESOURCE_NAME/gitRepo/terraform.tfstate
  if [ -f "$state_loc" ]; then
    echo "new state file exists, copying"
    echo "-----------------------------------"
    cp -vr /build/IN/$REPO_RESOURCE_NAME/gitRepo/terraform.tfstate /build/state/
  else
    echo "Copying previous state file"
    echo "-----------------------------------"
    local previous_statefile_location=/build/previousState/terraform.tfstate
    if [ -f "$previous_statefile_location" ]; then
      echo "previous state file exists, copying"
      echo "-----------------------------------"
      cp -vr previousState/terraform.tfstate /build/state/
    else
      echo "no previous state file exists. Skipping"
      echo "-----------------------------------"
    fi
  fi
}

main() {
  arch_statefile
}

main
