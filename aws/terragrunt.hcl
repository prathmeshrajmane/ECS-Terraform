locals {
  env_name = regex("environments/(?P<env>.*?)/.*", path_relative_to_include())

}

inputs = {
  env_name = local.env_name.env

}
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  backend "s3" {
    bucket         = "metadata-prod-util-b07eu"
    key            = "${local.env_name.env}/${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "metadata-terraform-state-lock-table-prod-b07eu"
  }
}
EOF
}
