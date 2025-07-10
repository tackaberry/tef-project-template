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
  folder_name            = "def"

  folder = data.terraform_remote_state.folders.outputs.folders[index(data.terraform_remote_state.folders.outputs.folders.*.display_name, local.folder_name )]

  region     = data.terraform_remote_state.bootstrap.outputs.common_config.default_region

  project_prefix = "cch"
  projects           =  jsondecode(file("projects.json"))

  billing_account = data.terraform_remote_state.bootstrap.outputs.common_config.billing_account_id
 
  base_host_project = data.terraform_remote_state.network.outputs.base_host_project_id
  base_network = data.terraform_remote_state.network.outputs.base_network_self_link
  base_subnets = data.terraform_remote_state.network.outputs.base_subnets_self_links

}

data "terraform_remote_state" "folders" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/projects/root_folders/${local.env}"
  }
}


resource "google_folder" "folder" {
  display_name = "fldr-${local.env}-simple-folder"
  parent       = local.folder.name
}


data "terraform_remote_state" "network" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/networks/${local.env}"
  }
}