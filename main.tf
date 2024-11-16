# aws_sso_access_module/main.tf
/*provider "aws" {
  region = var.region
}

# Data source for SSO instance
data "aws_ssoadmin_instances" "example" {}

# Call submodule for users
module "users" {
  source           = "./modules/users"
  identity_store_id = tolist(data.aws_ssoadmin_instances.example.identity_store_ids)[0]
}

# Call submodule for groups
module "groups" {
  source           = "./modules/groups"
  identity_store_id = tolist(data.aws_ssoadmin_instances.example.identity_store_ids)[0]
}

# Call submodule for permissions
module "permissions" {
  source           = "./modules/permissions"
  instance_arn     = tolist(data.aws_ssoadmin_instances.example.arns)[0]
}
*/
# aws_sso_access_module/main.tf
provider "aws" {
  region = var.region
}

# Data sources for SSO instance and identity store
data "aws_ssoadmin_instances" "example" {}

# The identity_store_id and instance_arn from the SSO instance
locals {
  identity_store_id = tolist(data.aws_ssoadmin_instances.example.identity_store_ids)[0]
  instance_arn      = tolist(data.aws_ssoadmin_instances.example.arns)[0]
}

# Call submodule for users
module "users" {
  source            = "./modules/users"
  identity_store_id = local.identity_store_id
}

# Call submodule for groups
module "groups" {
  source            = "./modules/groups"
  identity_store_id = local.identity_store_id
  member_id         = module.users.user_ids[0] # Example usage of user ID from users module
}

# Call submodule for permissions
module "permissions" {
  source       = "./modules/permissions"
  instance_arn = local.instance_arn
}
###############
# main.tf (Root Module)

module "sso_rbac_cross_account" {
  source                  = "./modules/sso-rbac-cross-account"
  accounts                = var.accounts
  organizational_units    = var.organizational_units
  roles                   = local.roles
  bindings                = local.bindings
}

###########
# Declare the groups variable
variable "groups" {
  description = "List of group names in AWS Identity Center"
  type        = list(string)
}
/*
# Declare the accounts variable
variable "accounts" {
  description = "List of AWS Account IDs for cross-account access"
  type        = list(string)
}

# Declare the roles variable with resources
variable "roles" {
  description = "Roles with associated resources for access"
  type        = map(object({
    name      = string
    resources = list(string)
  }))
}

# Declare the bindings variable
variable "bindings" {
  description = "List of group-to-role bindings per account"
  type        = list(object({
    group      = string
    account_id = string
    roles      = list(string)
  }))
}

# Example module for SSO RBAC configuration
module "sso_rbac_cross_account" {
  source = "dasmeta/identity-center/aws//modules/sso-rbac-cross-account"

  # Pass groups, accounts, roles, and bindings to the module
  groups    = var.groups
  accounts  = var.accounts
  roles     = var.roles
  bindings  = var.bindings
}
*/