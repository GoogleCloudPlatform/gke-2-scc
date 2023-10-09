# Copyright 2023 Google LLC

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     https://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

variable "organization_id" {
  description = "The ID of your Google Cloud Organization"
  type        = string
}

variable "integration_config" {
  description = "Resource allocation configuration for the GCF"
  type = object({
    available_memory                 = optional(string, "128Mi")
    available_cpu                    = optional(string, "1")
    timeout_seconds                  = optional(number, 10)
    max_instance_count               = optional(number, 1)
    max_instance_request_concurrency = optional(number, 100)
  })
}

variable "source_name" {
  description = "Override the name of the SCC Source that will be created "
  type        = string
  default     = "gke2scc"
}

variable "log_streaming_filter" {
  description = "The Cloud Logging inclusion filter for Audit Logs that should be streamed into SCC as findings"
  type        = string
}

variable "findings_config" {
  description = "list(FindingConfig) where FindingConfig == {\"method\"=\"$METHOD_NAME\", \"category\"=\"$CATEGORY_NAME\", \"severity\"=\"$SEVERITY_NAME\"}. Must include at least one finding config for the DEFAULT category to provide if the method is not found"

  type = list(object({
    method   = string
    category = string
    severity = optional(string, "")
  }))

  default = [{
    method   = "DEFAULT"
    category = "NO_CATEGORY_SPECIFIED"
  }]

  validation {
    condition     = anytrue([for idx, v in var.findings_config : v.method == "DEFAULT"])
    error_message = "You must at minimum provide a DEFAULT finding config if the method is not found"
  }

  validation {
    condition = alltrue([
      for k, v in var.findings_config :
      v.severity == "" ? true : length(regexall("^LOW|MEDIUM|HIGH|CRITICAL$", v.severity)) > 0
    ])
    error_message = "severity must be one of LOW, MEDIUM, HIGH, CRITICAL, or omitted (null)"
  }

  validation {
    condition     = length(distinct([for idx, v in var.findings_config : v.method])) == length(var.findings_config)
    error_message = "The `method` field must be unique for all findings"
  }
}