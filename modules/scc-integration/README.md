## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | ~> 2.4.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 4.78.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | ~> 4.78.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | ~> 2.4.0 |
| <a name="provider_google"></a> [google](#provider\_google) | ~> 4.78.0 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | ~> 4.78.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google-beta_google_project_service_identity.pubsub](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_project_service_identity) | resource |
| [google_cloudfunctions2_function.gke_2_scc_func](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions2_function) | resource |
| [google_eventarc_trigger.gke-cp-events](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/eventarc_trigger) | resource |
| [google_logging_organization_sink.gke_events](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_organization_sink) | resource |
| [google_organization_iam_member.gke_2_scc_func](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_project_iam_member.event_arc_sub_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.gke_2_scc_func](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.logging_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.pubsub_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_pubsub_topic.log_streaming](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_scc_source.gke](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/scc_source) | resource |
| [google_service_account.event_arc_sub_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.gke_2_scc_func](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_storage_bucket.gcf_artifacts](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_object.gke_2_scc_func](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [random_id.id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [archive_file.gke_2_scc_func](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [google_client_config.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_client_openid_userinfo.self](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_openid_userinfo) | data source |
| [google_project.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_findings_config"></a> [findings\_config](#input\_findings\_config) | list(FindingConfig) where FindingConfig == {"method"="$METHOD\_NAME", "category"="$CATEGORY\_NAME", "severity"="$SEVERITY\_NAME"}. Must include at least one finding config for the DEFAULT category to provide if the method is not found | <pre>list(object({<br>    method   = string<br>    category = string<br>    severity = optional(string, "")<br>  }))</pre> | <pre>[<br>  {<br>    "category": "NO_CATEGORY_SPECIFIED",<br>    "method": "DEFAULT"<br>  }<br>]</pre> | no |
| <a name="input_integration_config"></a> [integration\_config](#input\_integration\_config) | Resource allocation configuration for the GCF | <pre>object({<br>    available_memory                 = optional(string, "128Mi")<br>    available_cpu                    = optional(string, "1")<br>    timeout_seconds                  = optional(number, 10)<br>    max_instance_count               = optional(number, 1)<br>    max_instance_request_concurrency = optional(number, 100)<br>  })</pre> | n/a | yes |
| <a name="input_log_streaming_filter"></a> [log\_streaming\_filter](#input\_log\_streaming\_filter) | The Cloud Logging inclusion filter for Audit Logs that should be streamed into SCC as findings | `string` | n/a | yes |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | The ID of your Google Cloud Organization | `string` | n/a | yes |
| <a name="input_source_name"></a> [source\_name](#input\_source\_name) | Override the name of the SCC Source that will be created | `string` | `"gke2scc"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_logging_org_sink"></a> [logging\_org\_sink](#output\_logging\_org\_sink) | The Org sink for log streaming |
| <a name="output_pubsub_topic"></a> [pubsub\_topic](#output\_pubsub\_topic) | The Pub/Sub topic for log streaming |
