
module "groups" {
  for_each = local.groups

  source = "../../modules/group"

  group_name            = each.value.group_name
  group_description     = each.value.description
  members               = each.value.members
  directory_customer_id = local.directory_customer_id
  identity_domain       = local.identity_domain
}