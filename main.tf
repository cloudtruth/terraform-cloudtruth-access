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

resource "aws_iam_role" "cloudtruth_access" {
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

// This policy allows cloudtruth to write to your S3 buckets
//
data "aws_iam_policy_document" "s3_write" {

  statement {
    sid       = "BucketWrite"
    actions   = ["s3:PutObject"]
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
      "ssm:DescribeParameters",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    effect    = "Allow"
    resources = var.ssm_resources
  }

}

//  This policy allows cloudtruth to write to your AWS SSM Parameter Store
//
data "aws_iam_policy_document" "ssm_write" {

  statement {
    sid = "TagAccess"
    actions = [
      "tag:GetResources"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid = "ParameterWrite"
    actions = [
      "ssm:AddTagsToResource",
      "ssm:DeleteParameter",
      "ssm:ListTagsForResource",
      "ssm:PutParameter",
      "ssm:RemoveTagsFromResource"
    ]
    effect    = "Allow"
    resources = var.ssm_resources
  }

}

//  This policy allows cloudtruth to list and read your AWS Secrets Manager Store
//
data "aws_iam_policy_document" "secretsmanager" {

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
    resources = var.secretsmanager_resources
  }

}

//  This policy allows cloudtruth to write to your AWS Secret Manager Store
//
data "aws_iam_policy_document" "secretsmanager_write" {

  statement {
    sid = "SecretWrite"
    actions = [
      "secretsmanager:CreateSecret",
      "secretsmanager:DeleteSecret",
      "secretsmanager:TagResource",
      "secretsmanager:UpdateSecret"
    ]
    effect    = "Allow"
    resources = var.secretsmanager_resources
  }

}

//  This policy allows cloudtruth to perform kms decrypt operations using the specified key(s)
//
data "aws_iam_policy_document" "kms_decrypt" {

  statement {
    sid    = "AllowKMSDecrypt"
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]
    resources = var.kms_keys
  }
}

//  This policy allows cloudtruth to perform kms encrypt operations using the specified key(s)
//
data "aws_iam_policy_document" "kms_encrypt" {

  statement {
    sid    = "AllowKMSEncrypt"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:GenerateDataKey"
    ]
    resources = var.kms_keys
  }
}

locals {
  policy_lookup = {
    s3             = var.s3_policy != "" ? var.s3_policy : data.aws_iam_policy_document.s3.json
    ssm            = var.ssm_policy != "" ? var.ssm_policy : data.aws_iam_policy_document.ssm.json
    secretsmanager = var.secretsmanager_policy != "" ? var.secretsmanager_policy : data.aws_iam_policy_document.secretsmanager.json
  }
  write_policy_lookup = {
    s3             = data.aws_iam_policy_document.s3_write.json
    ssm            = data.aws_iam_policy_document.ssm_write.json
    secretsmanager = data.aws_iam_policy_document.secretsmanager_write.json
  }
}

resource "aws_iam_role_policy" "cloudtruth_policies" {
  for_each = toset(var.services_enabled)

  name   = "allow-cloudtruth-access-to-${each.key}"
  role   = aws_iam_role.cloudtruth_access.id
  policy = local.policy_lookup[each.key]
}

resource "aws_iam_role_policy" "cloudtruth_write_policies" {
  for_each = toset(var.services_write_enabled)

  name   = "allow-cloudtruth-write-to-${each.key}"
  role   = aws_iam_role.cloudtruth_access.id
  policy = local.write_policy_lookup[each.key]
}

resource "aws_iam_role_policy" "cloudtruth_kms_decrypt" {
  count  = var.kms_decrypt_enabled || var.kms_encrypt_enabled ? 1 : 0
  name   = "allow-cloudtruth-kms-decrypt"
  role   = aws_iam_role.cloudtruth_access.id
  policy = data.aws_iam_policy_document.kms_decrypt.json
}

resource "aws_iam_role_policy" "cloudtruth_kms_encrypt" {
  count  = var.kms_encrypt_enabled ? 1 : 0
  name   = "allow-cloudtruth-kms-encrypt"
  role   = aws_iam_role.cloudtruth_access.id
  policy = data.aws_iam_policy_document.kms_encrypt.json
}
