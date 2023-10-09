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
  source_name = "${var.source_name == "gke2scc" ? "GKE 2 SCC" : var.source_name} - ${local.random_id}"
}

resource "google_scc_source" "gke" {

  display_name = local.source_name
  organization = var.organization_id
  description  = "Custom Cloud Security Command Center Finding Source for gke-2-scc findings"
}