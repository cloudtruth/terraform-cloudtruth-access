variable "role_name" {
  description = "The role within your AWS account that cloudtruth will assume to perform its actions"
}

variable "external_id" {
  description = "The external id used for limiting access"
}

variable "cloudtruth_account_id" {
  description = "The AWS account ID for the cloudtruth account that will be assuming the role"
  default = "811566399652"
}

variable "services_allowed" {
  description = <<-EOD
    The AWS services to grant cloudtruth access to, defaults to s3 and ssm
  EOD
  type = list(string)
  default = ["s3", "ssm"]
}

variable "s3_resources" {
  description = <<-EOD
    The s3 resources to explicitly grant access to, defaults to all, and listing
    all buckets is always allowed (for bucket chooser in UI) even if access
    isn't granted here
  EOD
  type = list(string)
  default = ["*"]
}

variable "s3_policy" {
  description = <<-EOD
    A custom poilicy to use for s3 instead of the one this module would define
  EOD
  default = ""
}

variable "ssm_resources" {
  description = <<-EOD
    The ssm resources to explicitly grant access to, defaults to all, and listing
    all buckets is always allowed (for bucket chooser in UI) even if access
    isn't granted here
  EOD
  type = list(string)
  default = ["*"]
}

variable "ssm_policy" {
  description = <<-EOD
    A custom poilicy to use for ssm instead of the one this module would define
  EOD
  default = ""
}
