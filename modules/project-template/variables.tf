variable "project_name" {
  description = "The name of the project to be created."
  type        = string

}

variable "editor_group" {
  description = "The email of the group that will be granted editor roles."
  type        = list(string)
}

variable "identity_domain" {
  description = "The domain associated with the Google Workspace / Cloud Identity account."
  type        = string
}


variable "metadata" {
  description = "Metadata to be associated with the project."
  type = object({
    type             = string
    data_classification = string
  })
  default     = {
    type = "client"
    data_classification = "unclass"
  }
}

variable "billing_account" {
  description = "The billing account to be associated with the project."
  type        = string
}

variable "folder" {
  description = "The folder ID where the project will be created."
  type        = string
}

variable "project_prefix" {
  description = "The prefix for the project ID."
  type        = string
}

variable "base_host_project" {
  description = "The base host project ID for network resources."
  type        = string
}

variable "base_subnets" {
  description = "The base subnets for network resources."
  type        = list(string)
}