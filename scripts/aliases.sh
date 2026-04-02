# Copyright 2024 Google LLC

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

tginit() {
    DIR="$1"
    terragrunt run --working-dir ${DIR} -- init 
}

tgval() {
    DIR="$1"
    terragrunt run --working-dir ${DIR} -- validate 
}


tgconsole() {
    DIR="$1"
    terragrunt run --working-dir ${DIR} -- console 
}
alias tgcon="tgconsole"

tgtaint() {
    DIR="$1"
    terragrunt run --working-dir ${DIR} -- taint  
}

tgplan() {
    DIR="$1"
    terragrunt run --working-dir ${DIR} -- plan  
}

tgapply() {
    DIR="$1"
    terragrunt run --working-dir ${DIR} -- apply  
}

tgdestroy() {
    DIR="$1"
    terragrunt run --working-dir ${DIR} -- destroy  
}

tgout() {
    DIR="$1"
    terragrunt run --working-dir ${DIR} -- out  
}

alias glogin="gcloud auth login --update-adc --no-launch-browser"
alias tffmt="terragrunt hcl fmt hclfmt && terraform fmt -recursive"
alias k="kubectl"

tgswitch() {
    DIR="$1"
    if [[ ${DIR} == "" ]]
    then
        echo 'Must provide a valid directory as an argument!'
    else
        (cd $1; tfswitch)
    fi
}

cd-repo-root() {
    while [[ ! -d ./.git ]]
    do
        cd ..
    done
}

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:/usr/local/google-cloud-sdk/bin:$PATH"