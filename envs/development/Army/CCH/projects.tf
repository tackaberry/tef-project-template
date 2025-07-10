module "cch_projects" {
  for_each = local.projects
  source = "../../modules/cch-project-template"

  project_name        = each.value.project_name
  editor_group        = each.value.editor_group


  billing_account = local.billing_account
  folder = local.folder
  project_prefix = local.project_prefix
  base_host_project = local.base_host_project
  base_subnets = local.base_subnets

}

output "created_projects" {
  description = "A map of the created projects and their details."
  value = {
    for key, project in module.cch_projects : key => {
      name           = project.name
      project_id     = project.project_id
      project_number = project.project_number
    }
  }
}
