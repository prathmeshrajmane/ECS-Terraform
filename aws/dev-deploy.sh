#!/bin/bash
set -e
cd environments/dev

terragrunt run-all init
terragrunt run-all plan
terragrunt run-all apply --terragrunt-non-interactive
cd ../../
