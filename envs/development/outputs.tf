
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
