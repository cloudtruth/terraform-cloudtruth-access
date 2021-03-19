# Grant Cloudtruth Access

Sets up a role and uses it to grant cloudtruth the permission to access the
given resources within your aws account

## Usage

```hcl
module "grant-cloudtruth-access" {
  source = "github.com/cloudtruth/terraform-cloudtruth-access"

  role_name = "name-the-role-as-desired-matches-that-on-cloudtruth-integration-page"
  external_id = "generated-external-id-from-cloudtruth-integration-page"
  services_enabled = ["s3"]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account\_ids | The AWS account IDs (for the cloudtruth account) that will be assuming the role | `list(string)` | <pre>[<br>  "811566399652"<br>]</pre> | no |
| external\_id | The external id used for limiting access. | `any` | n/a | yes |
| role\_name | The role within your AWS account that cloudtruth will assume to perform its actions | `any` | n/a | yes |
| s3\_policy | A custom policy to use for s3 instead of the one this module would define | `string` | `""` | no |
| s3\_resources | The s3 resources to explicitly grant access to, defaults to all, and listing<br>all buckets is always allowed (for bucket chooser in UI) even if access<br>isn't granted here | `list(string)` | <pre>[<br>  "*"<br>]</pre> | no |
| services\_enabled | The AWS services to grant cloudtruth access to, allowed values are s3, ssm, secrets | `list(string)` | n/a | yes |
| ssm\_policy | A custom policy to use for ssm instead of the one this module would define | `string` | `""` | no |
| ssm\_resources | The ssm resources to explicitly grant access to, defaults to all, and listing<br>all is always allowed (for chooser in UI) even if access<br>isn't granted here | `list(string)` | <pre>[<br>  "*"<br>]</pre> | no |
| secrets\_policy | A custom policy to use for secrets manager instead of the one this module would define | `string` | `""` | no |
| secrets\_resources | The secrets manager resources to explicitly grant access to, defaults to all, and listing<br>all is always allowed (for chooser in UI) even if access<br>isn't granted here | `list(string)` | <pre>[<br>  "*"<br>]</pre> | no |

## Outputs

No output.

