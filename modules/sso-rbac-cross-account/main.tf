# modules/sso-rbac-cross-account/main.tf

# Data source to get AWS SSO instance ARN
data "aws_ssoadmin_instances" "current" {}

# Create permission sets based on the roles defined in the locals
resource "aws_ssoadmin_permission_set" "cross_account_permissions" {
  for_each        = { for role in var.roles : role.name => role }
  instance_arn    = tolist(data.aws_ssoadmin_instances.current.arns)[0]
  name            = each.value.name
  relay_state     = "https://console.aws.amazon.com/"
  session_duration = "PT4H"
}

# Attach the permissions defined in roles
resource "aws_iam_policy" "role_policies" {
  for_each = { for role in var.roles : role.name => role }

  name   = "${each.value.name}-policy"
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = each.value.actions,
        Resource = each.value.resources
      }
    ]
  })
}

# Attach policies to permission sets
resource "aws_ssoadmin_managed_policy_attachment" "policy_attachment" {
  for_each = { for role in var.roles : role.name => role }

  instance_arn       = tolist(data.aws_ssoadmin_instances.current.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.cross_account_permissions[each.key].arn
  managed_policy_arn = aws_iam_policy.role_policies[each.key].arn
}

# Create account assignments based on bindings
resource "aws_ssoadmin_account_assignment" "cross_account_assignments" {
  for_each           = { for binding in var.bindings : "${binding.account_id}-${binding.group}" => binding }
  instance_arn       = tolist(data.aws_ssoadmin_instances.current.arns)[0]
  principal_id       = each.value.group
  principal_type     = "GROUP"
  permission_set_arn = aws_ssoadmin_permission_set.cross_account_permissions[each.value.roles[0]].arn
  target_id          = each.value.account_id
  target_type        = "AWS_ACCOUNT"
}

# IAM Access Analyzer to monitor for least-privilege adherence
resource "aws_accessanalyzer_analyzer" "sso_analyzer" {
  analyzer_name = "sso-access-analyzer"
  type          = "ORGANIZATION"
}

#############

