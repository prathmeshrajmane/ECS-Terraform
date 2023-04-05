#!/bin/bash
set -e
cd aws/environments/dev

terragrunt run-all init
terragrunt run-all plan -lock=false
terragrunt run-all apply --terragrunt-non-interactive -lock=false
cd ../../
