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

locals {
  gke_2_scc_sa_project_roles = toset([

  ])
  gke_2_scc_sa_org_roles = toset([
    "roles/securitycenter.adminEditor"
  ])
}

################################################## 
#
#             GKE_2_SCC Func SA
#
##################################################
resource "google_service_account" "gke_2_scc_func" {

  account_id = "gke-2-scc-sa-${local.random_id}"

  display_name = "SA GKE-2-SCC function - ${local.random_id}"
}

resource "google_project_iam_member" "gke_2_scc_func" {
  for_each = local.gke_2_scc_sa_project_roles

  project = local.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_2_scc_func.email}"
}

resource "google_organization_iam_member" "gke_2_scc_func" {
  for_each = local.gke_2_scc_sa_org_roles

  org_id = var.organization_id
  role   = each.value
  member = "serviceAccount:${google_service_account.gke_2_scc_func.email}"
}

# Package the function
data "archive_file" "gke_2_scc_func" {

  type        = "zip"
  source_dir  = "${path.module}/src/gke-2-scc"
  output_path = "gke-2-scc.zip"
}

# Upload to GCS
resource "google_storage_bucket_object" "gke_2_scc_func" {

  # Append file hash to force bucket object to be recreated
  name   = "functions/gke-2-scc-${local.random_id}/versions/${data.archive_file.gke_2_scc_func.output_sha256}.zip"
  bucket = google_storage_bucket.gcf_artifacts.name
  source = data.archive_file.gke_2_scc_func.output_path
}

locals {
  severity_map = {
    ""       = 0,
    CRITICAL = 1,
    HIGH     = 2,
    MEDIUM   = 3,
    LOW      = 4
  }
  finding_config = {
    for _, v in var.findings_config :
    v.method => merge(v, {
      "severity" = local.severity_map[v.severity]
    })
  }
}

# Deploy to GCF v2
resource "google_cloudfunctions2_function" "gke_2_scc_func" {

  name        = "gke-2-scc-${local.random_id}"
  location    = local.region
  description = "Cloud Function to stream GKE Audit Log events into Security Command Center"

  build_config {
    runtime     = "go119"
    entry_point = "Handler" # Set the entry point 
    source {
      storage_source {
        bucket = google_storage_bucket_object.gke_2_scc_func.bucket
        object = google_storage_bucket_object.gke_2_scc_func.name
      }
    }
  }

  service_config {
    available_memory                 = var.integration_config.available_memory
    available_cpu                    = var.integration_config.available_cpu
    timeout_seconds                  = var.integration_config.timeout_seconds
    max_instance_count               = var.integration_config.max_instance_count
    max_instance_request_concurrency = var.integration_config.max_instance_request_concurrency
    ingress_settings                 = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision   = true
    service_account_email            = google_service_account.gke_2_scc_func.email

    environment_variables = {
      SCC_SOURCE_ID      = google_scc_source.gke.id
      SCC_FINDING_CONFIG = jsonencode(local.finding_config)
    }
  }
}