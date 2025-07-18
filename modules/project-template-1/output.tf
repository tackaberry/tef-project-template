output "name" {
  value = local.project_name
}

output "project_id" {
  value = google_project.main.project_id
}

output "project_number" {
  value = google_project.main.number
}   