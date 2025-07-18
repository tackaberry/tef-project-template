module "projects" {
  for_each = local.projects
  source   = "../../modules/project-template-1"

  project_name = each.value.project_name
  editor_group = each.value.editor_group

  metadata = each.value.metadata


  billing_account   = local.billing_account
  folder            = local.folder
  project_prefix    = local.project_prefix
  base_host_project = local.base_host_project
  base_subnets      = local.base_subnets

}

output "created_projects" {
  description = "A map of the created projects and their details."
  value = {
    for key, project in module.projects : key => {
      name           = project.name
      project_id     = project.project_id
      project_number = project.project_number
    }
  }
}
