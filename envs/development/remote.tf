locals {

  env                = "development"
  folder_name        = "group-1"
  project_prefix     = "group1"

  parent_folder_name = data.terraform_remote_state.env.outputs.env_folder

  region = data.terraform_remote_state.bootstrap.outputs.common_config.default_region
  organization = data.terraform_remote_state.bootstrap.outputs.common_config.org_id

  directory_customer_id = data.google_organization.org.directory_customer_id
  identity_domain      = data.google_organization.org.domain

  projects = jsondecode(file("projects.json"))
  groups  = jsondecode(file("groups.json"))

  billing_account = data.terraform_remote_state.bootstrap.outputs.common_config.billing_account

  base_host_project = data.terraform_remote_state.network.outputs.base_host_project_id
  base_network      = data.terraform_remote_state.network.outputs.base_network_self_link
  base_subnets      = data.terraform_remote_state.network.outputs.base_subnets_self_links

}

data "google_organization" "org" {
  organization = local.organization
}

data "terraform_remote_state" "bootstrap" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/bootstrap/state"
  }
}

data "terraform_remote_state" "env" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/environments/${local.env}"
  }
}

data "terraform_remote_state" "org" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/org/state"
  }
}


data "terraform_remote_state" "network" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/networks/${local.env}"
  }
}