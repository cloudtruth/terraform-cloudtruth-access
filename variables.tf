variable "role_name" {
  description = "The role within your AWS account that cloudtruth will assume to perform its actions"
}

variable "external_id" {
  description = "The external id used for limiting access"
}

variable "account_ids" {
  description = "The AWS account IDs (for the cloudtruth account) that will be assuming the role"
  type        = list(string)
  default     = ["609878994716"]
}

variable "services_enabled" {
  description = <<-EOD
    The AWS services to grant cloudtruth access to, allowed values are s3, ssm, secretsmanager, kms
  EOD
  type        = list(string)
}

variable "services_write_enabled" {
  description = <<-EOD
    The AWS services to grant cloudtruth write access to, allowed values are s3, ssm, secretsmanager, kms
  EOD
  type        = list(string)
  default     = []
}

variable "s3_resources" {
  description = <<-EOD
    The s3 resources to explicitly grant access to, defaults to all, and listing
    all buckets is always allowed (for bucket chooser in UI) even if access
    isn't granted here
  EOD
  type        = list(string)
  default     = ["*"]
}

variable "s3_policy" {
  description = <<-EOD
    A custom policy to use for s3 instead of the one this module would define
  EOD
  default     = ""
}

variable "ssm_resources" {
  description = <<-EOD
    The ssm resources to explicitly grant access to, defaults to all
  EOD
  type        = list(string)
  default     = ["*"]
}

variable "ssm_policy" {
  description = <<-EOD
    A custom policy to use for ssm instead of the one this module would define
  EOD
  default     = ""
}

variable "secretsmanager_resources" {
  description = <<-EOD
    The secrets manager resources to explicitly grant access to, defaults to all, and listing
    is always allowed (for chooser in UI) even if access isn't granted here
  EOD
  type        = list(string)
  default     = ["*"]
}

variable "secretsmanager_policy" {
  description = <<-EOD
    A custom policy to use for secrets manager instead of the one this module would define
  EOD
  default     = ""
}

variable "kms_keys" {
  description = <<-EOD
    The kms keys to explicitly grant access to, defaults to none
  EOD
  type        = list(string)
  default     = []
}

variable "kms_policy" {
  description = <<-EOD
    A custom policy to use for kms key access instead of the one this module would define
  EOD
  default     = ""
}
