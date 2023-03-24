#!/bin/bash
set -e
cd aws/environments/dev

terragrunt run-all destroy --terragrunt-non-interactive
cd ../../
