variable "repository" {
  type        = string
  description = "GitHub repository in owner/repo format."
}

variable "cidr" {
  type        = string
  default     = "10.0.0.0/24"
  description = "CIDR notation for the subnet block."
}

variable "floating_network" {
  type        = string
  default     = "floating"
  description = "Name of the floating IP network."
}

variable "floating_subnet" {
  type        = string
  default     = "floating-subnet"
  description = "Name of the floating IP network."
}

variable "flavor_name" {
  type        = string
  default     = "large"
  description = "The name of the flavor for the runner VM."
}

variable "image" {
  type = object({
    name       = string
    visibility = string
  })
  default = {
    name       = "Ubuntu-20.04"
    visibility = "public"
  }
  description = "Name and visibility of the image to boot."
}

variable "volume_size" {
  type        = number
  default     = 50
  description = "Size of the OS disk."
}

variable "proxy_settings" {
  type = object({
    proxy    = string
    no_proxy = optional(string)
  })
  default     = { proxy = "" }
  description = "Optionally set proxy variables for runner installation, they persist in runtime as well."
}

variable "personal_access_token_secret" {
  type        = string
  default     = "github-personal-access-token"
  description = "Name of the secret containing the github PAT. The PAT must the only content of the secret."
}

variable "labels" {
  type        = list(string)
  description = "Labels used by Github to target the runner"
}

variable "admin_group" {
  type        = string
  description = "Unix group that has ssh and sudo access."
}

locals {
  named_resources_string = "${replace(var.repository, "/", "-")}-runner"
}
