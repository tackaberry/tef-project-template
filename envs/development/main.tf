terraform {
  # backend "gcs" {
  #   bucket = "bkt-prj-b-seed-tfstate-nnnn"
  #   prefix = "terraform/projects/base_business_unit/development"
  # }
}

variable "remote_state_bucket" {
  description = "Backend bucket to load Terraform Remote State Data from previous steps."
  type        = string
}

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

resource "google_folder" "folder" {
  display_name = "fldr-${local.folder_name}"
  parent       = local.parent_folder_name
}

resource "google_folder" "folder_unclass" {
  display_name = "fldr-${local.folder_name}-unclass"
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
  display_name              = "fldr-${local.folder_name}-pb-${random_string.suffix.result}"
  location                  = "ca"
  organization              = local.organization
  billing_account           = "billingAccounts/${local.billing_account}"
  enable_sovereign_controls = true

  provisioned_resources_parent = google_folder.folder.name  

  resource_settings {
    resource_type = "CONSUMER_FOLDER"
  }

  provider                  = google-beta
  depends_on = [google_project_service.dependency_project_api] 
}

resource "random_string" "suffix" {
  length  = 5
  upper   = false
  special = false
}

resource "google_project" "dependency_project" {
  name                = "dep-${local.env}-${local.project_prefix}"
  project_id          = "dep-${local.env}-${local.project_prefix}-${random_string.suffix.result}"
  folder_id           = google_folder.folder.name
  billing_account     = local.billing_account
  auto_create_network = false
  deletion_policy     = "DELETE"
}


resource "google_project_service" "dependency_project_api" {

  project            = google_project.dependency_project.project_id
  service            = "assuredworkloads.googleapis.com"
  disable_on_destroy = false
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