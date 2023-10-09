## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 4.76.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | ~> 4.76.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 4.76.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_project_organization_policy.disabled_boolean_policies](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_organization_policy) | resource |
| [google_project_organization_policy.disabled_list_policies](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_organization_policy) | resource |
| [google_project.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_boolean_policies_to_disable"></a> [boolean\_policies\_to\_disable](#input\_boolean\_policies\_to\_disable) | A list of boolean Org Policies to disable for the project | `list(string)` | `[]` | no |
| <a name="input_list_constraint_policies_to_disable"></a> [list\_constraint\_policies\_to\_disable](#input\_list\_constraint\_policies\_to\_disable) | A list of list constraint Org Policies to disable for the project | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_disabled_boolean_policies"></a> [disabled\_boolean\_policies](#output\_disabled\_boolean\_policies) | The boolean Org Policies that were disabled for this project |
| <a name="output_disabled_list_constraint_policies"></a> [disabled\_list\_constraint\_policies](#output\_disabled\_list\_constraint\_policies) | The list constraint Org Policies that were disabled for this project |
