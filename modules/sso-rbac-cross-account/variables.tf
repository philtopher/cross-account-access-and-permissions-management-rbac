# modules/sso-rbac-cross-account/variables.tf

variable "accounts" {
  description = "List of AWS account IDs for cross-account access"
  type        = list(string)
}

variable "organizational_units" {
  description = "List of AWS OU IDs for cross-account access (optional)"
  type        = list(string)
  default     = []
}

variable "roles" {
  description = "List of roles with permissions, actions, and resources for cross-account access"
  type        = list(object({
    name               = string
    permission_set_arn = string
    actions            = list(string)
    resources          = list(string)
  }))
}

variable "bindings" {
  description = "User/group bindings to roles with specific accounts"
  type        = list(object({
    group      = string
    account_id = string
    roles      = list(string)
  }))
}
