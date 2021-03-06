locals {
  external_ids = compact(split(",", var.external_id))
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    sid     = "AllowCloudtruthToAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:root", var.account_ids)
    }

    dynamic "condition" {
      for_each = length(local.external_ids) > 0 ? [1] : []
      content {
        test     = "StringEquals"
        variable = "sts:ExternalId"

        values = local.external_ids
      }
    }

  }
}

resource "aws_iam_role" "cloudtruth-access" {
  description = "The role that cloudtruth will assume in order to access your AWS account"
  name        = var.role_name

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

// This policy allows cloudtruth to list and read your S3 buckets
//
data "aws_iam_policy_document" "s3" {

  statement {
    sid       = "BucketSelection"
    actions   = ["s3:ListAllMyBuckets"]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid       = "BucketAccess"
    actions   = ["s3:GetBucketLocation", "s3:ListBucket", "s3:GetObject"]
    effect    = "Allow"
    resources = var.s3_resources
  }

}

//  This policy allows cloudtruth to list and read your AWS SSM Parameter Store
//
data "aws_iam_policy_document" "ssm" {

  statement {
    sid = "ParameterList"
    actions = [
      "ssm:DescribeParameters"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid = "ParameterAccess"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    effect    = "Allow"
    resources = var.ssm_resources
  }

}

//  This policy allows cloudtruth to list and read your AWS Secret Store
//
data "aws_iam_policy_document" "secrets" {

  statement {
    sid = "ListSecrets"
    actions = [
      "secretsmanager:ListSecrets"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid = "SecretAccess"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    effect    = "Allow"
    resources = var.secrets_resources
  }

}

locals {
  policy_lookup = {
    s3  = var.s3_policy != "" ? var.s3_policy : data.aws_iam_policy_document.s3.json
    ssm = var.ssm_policy != "" ? var.ssm_policy : data.aws_iam_policy_document.ssm.json
    secrets = var.secrets_policy != "" ? var.secrets_policy : data.aws_iam_policy_document.secrets.json
  }
}

resource "aws_iam_role_policy" "cloudtruth-policies" {
  for_each = toset(var.services_enabled)

  name   = "allow-cloudtruth-access-to-${each.key}"
  role   = aws_iam_role.cloudtruth-access.id
  policy = local.policy_lookup[each.key]
}
