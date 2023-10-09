  
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

# Terragrunt & Terraform aliases
alias tf="terraform"
alias tg="terragrunt"
alias tginit="terragrunt init --terragrunt-working-dir"
alias tgval="terragrunt validate --terragrunt-working-dir"
alias tgconsole="terragrunt console --terragrunt-working-dir"
alias tgcon="tgconsole"
alias tgtaint="terragrunt taint --terragrunt-working-dir"
alias tgplan="terragrunt plan --terragrunt-working-dir"
alias tgapply="terragrunt apply --terragrunt-working-dir"
alias tgdestroy="terragrunt destroy --terragrunt-working-dir"
alias glogin="gcloud auth login --update-adc"

tgswitch() {
    DIR="$1"
    if [[ ${DIR} == "" ]]
    then
        echo 'Must provide a valid directory as an argument!'
    else
        (cd $1; tfswitch)
    fi
}
  
  