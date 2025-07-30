terraform {
  backend "gcs" {
    bucket = "bkt-prj-b-seed-tfstate-nnnn"
    prefix = "terraform/projects/base_business_unit/development"
  }
}

variable "remote_state_bucket" {
  description = "Backend bucket to load Terraform Remote State Data from previous steps."
  type        = string
}


locals {

  env                = "development"
  parent_folder_name = "level1"
  folder_name        = "group-1"
  project_prefix     = "group1"

  folder = data.terraform_remote_state.folders.outputs.folders[index(data.terraform_remote_state.folders.outputs.folders.*.display_name, local.folder_name)]

  region = data.terraform_remote_state.bootstrap.outputs.common_config.default_region
  organization = data.terraform_remote_state.bootstrap.outputs.common_config.org_id

  projects = jsondecode(file("projects.json"))

  billing_account = data.terraform_remote_state.bootstrap.outputs.common_config.billing_account_id

  base_host_project = data.terraform_remote_state.network.outputs.base_host_project_id
  base_network      = data.terraform_remote_state.network.outputs.base_network_self_link
  base_subnets      = data.terraform_remote_state.network.outputs.base_subnets_self_links

}

resource "google_folder" "folder" {
  display_name = "fldr-${local.env}-${local.folder_name}"
  parent       = local.parent_folder_name
}

resource "google_folder" "folder_unclass" {
  display_name = "fldr-${local.env}-${local.folder_name}-unclass"
  parent       = google_folder.folder.name
}


# Enable the Assured Workloads API in the dependency project
resource "google_project_service" "enable_api_aw" {
  service                    = "assuredworkloads.googleapis.com"
  project                    = google_project.dependency_project.project_id
  disable_on_destroy         = false
  disable_dependent_services = false
  depends_on                 = [google_project.dependency_project]
}

resource "google_assured_workloads_workload" "folder_pb" {
  compliance_regime         = "CA_PROTECTED_B"
  display_name              = "fldr-${local.env}-${local.folder_name}-pb"
  location                  = "ca"
  organization              = local.organization
  billing_account           = local.billing_account
  enable_sovereign_controls = true

  resource_settings {
    resource_type = "CONSUMER_FOLDER"
  }

  provider                  = google-beta
}

data "terraform_remote_state" "bootstrap" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/bootstrap/state"
  }
}


data "terraform_remote_state" "folders" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/projects/root_folders/${local.env}"
  }
}

data "terraform_remote_state" "network" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/networks/${local.env}"
  }
}