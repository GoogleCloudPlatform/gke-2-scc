# Copyright 2025 Google LLC

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     https://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

imgRegistry="us-central1-docker.pkg.dev"
gcpProject="nam-sdbx"
imgRepo="gdc-solutions"
imgName="gke-2-scc-devcontainer"
img=${imgRegistry}/${gcpProject}/${imgRepo}/${imgName}
version = "0.0.1"

cleanup: delete-tf-locks delete-tg-cache fmt

.PHONY: build-devcontainer
build-pdk:
	@echo "Building image: $(img):$(version)"
	@devcontainer build --workspace-folder . --push true --image-name  $(img):$(version)

.PHONY: delete-tf-locks
delete-tf-locks:
	@find ./ -type f -name ".terraform.lock.hcl" -delete

.PHONY: delete-tg-cache
delete-tg-cache:
	@find ./ -type d -name ".terragrunt-cache" -exec rm -rf {} +

.PHONY: fmt
fmt:
	@terragrunt hcl fmt
	@terraform fmt -recursive 