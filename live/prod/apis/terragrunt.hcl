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

skip = false

include "common" {
  path = find_in_parent_folders("common.hcl")
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("shared.hcl"))
  config      = yamldecode(file("${get_repo_root()}/config.yml"))
  envConfig   = local.config[basename(dirname("${get_terragrunt_dir()}../../"))]
}

terraform {
  source = "${get_repo_root()}/modules/apis"

  before_hook "enable_resource_manager_api" {
    commands = ["plan", "apply"]
    execute  = ["gcloud", "services", "enable", "cloudresourcemanager.googleapis.com", "--project=${local.envConfig["projectId"]}"]
  }

  after_hook "allow_api_propagation" {
    commands     = ["apply"]
    execute      = ["sleep", "60"]
    run_on_error = false
  }
}

inputs = {
  // Reference your shared list of APIs to enable here (these should be consistent across all environments)
  services = local.common_vars.inputs.services
}