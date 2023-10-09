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

skip = true

locals {
  config    = yamldecode(file("${get_repo_root()}/config.yml"))
  envConfig = local.config[basename(dirname("${get_terragrunt_dir()}../../"))]
}

remote_state {
  backend = "gcs"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    project  = local.config.terraformState["projectId"]
    location = local.config.terraformState["region"]
    bucket   = "${local.config.terraformState["projectId"]}-tf-state"
    prefix   = "terraform/state/gke-2-scc/${path_relative_to_include()}"
  }
}

generate "provider" {

  path      = "provider.tf"
  if_exists = "overwrite"

  contents = <<EOF
provider "google" {
  region                      = "${local.envConfig["region"]}"
  project                     = "${local.envConfig["projectId"]}"
  user_project_override       = true
  billing_project             = "${local.envConfig["projectId"]}"
}

provider "google-beta" {
  region                      = "${local.envConfig["region"]}"
  project                     = "${local.envConfig["projectId"]}"
  user_project_override       = true
  billing_project             = "${local.envConfig["projectId"]}"
}
EOF
}
