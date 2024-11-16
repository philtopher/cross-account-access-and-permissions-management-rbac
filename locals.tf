# locals.tf

locals {
  roles = [{
    name               = "viewers"
    permission_set_arn = "<SSO Permission Set ARN for Viewer>"
    actions            = ["get", "list", "describe"]
    resources          = ["arn:aws:s3:::demo-dgcl/*"]  # Example for S3 bucket access
  }, {
    name               = "editors"
    permission_set_arn = "<SSO Permission Set ARN for Editor>"
    actions            = ["put", "get", "list", "delete"]
    resources          = ["arn:aws:s3:::demo-dgcl/*"]  # Example for S3 bucket access
  }]

  bindings = [{
    group      = "developers"
    account_id = "925305174329"       # Target Account ID
    roles      = ["viewers", "editors"]
  }, {
    group      = "accountants"
    account_id = "098765432109"       # Another Account ID
    roles      = ["editors"]
  }]
}
