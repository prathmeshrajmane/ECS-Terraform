include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/ecs"
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()

    arguments = [
      "-var-file=${get_parent_terragrunt_dir()}/dev.tfvars"
    ]
  }

dependency "roles" {
    config_path = "../roles"
    mock_outputs = {
      aws_role_arn = "ecsTaskExecutionRole"
      
    }
  }


dependency "vpc" {
    config_path = "../vpc"
    mock_outputs = {
      alb_arn = "target_group"
      default_subnet_a.id = ["default_subnet_a" , "default_subnet_b" , "default_subnet_c"]
    }
  }


inputs = {
  aws_role_arn  = dependency.roles.outputs.aws_role_arn
  alb_arn = dependency.vpc.outputs.alb_arn
  default_subnet_a = dependency.vpc.outputs.default_subnet_a.id
}
