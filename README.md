Sets up a role and uses it to grant cloudtruth the permission to access the
given resources within your aws account

Usage:

```hcl
module "grant-cloudtruth-access" {
  source = "github.com/cloudtruth/terraform-cloudtruth-access"

  role_name = "name-the-role-as-desired"
  external_id = "generated-external-id"
}
```
