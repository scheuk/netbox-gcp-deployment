#!/usr/bin/env bash
set -e

#terraform=$(garden tools terraform.terraform-1-0-5 --get-path)
terraform=$(which terraform) 
terraform_bucket_target="google_storage_bucket.project_bucket"
bucket_name="$1-state"
google_project_id="$1"
terraform_dir="$2"
terraform_bucket_dir="$2/bucket"

Help()
{
   # Display Help
   echo "This script will bootstrap your sandbox project."
   echo "with a google storage bucket to store terraform state"
   echo
   echo "Syntax: bootstrap.sh <project_id> <terraform_dir>"
   echo "option:"
   echo "<project_id>     Replace this with your GCP project ID"
   echo "<terraform_dir>  Replace this with the relative path to your terraform project folder"
   echo
}

function create_backend_tf {
    cat <<EOF > $1/backend.tf
terraform {
  backend "gcs" {
    bucket  = "$bucket_name"
    prefix  = "$2/state"
  }
}
EOF
}

function validate_terraform {
    $terraform -chdir=$terraform_dir validate -json
}

function create_bucket_and_migrate_state {
    $terraform -chdir=$terraform_bucket_dir init
    $terraform -chdir=$terraform_bucket_dir apply -auto-approve -input=false -var="project_id=$google_project_id"
    create_backend_tf $terraform_bucket_dir "bucket"
    $terraform -chdir=$terraform_bucket_dir init -migrate-state -force-copy
    echo "Successfully created state bucket and migrated terrform state to the bucket"
}

# check input
if [ -z $1 ] || [ -z $2 ]; then
        Help
        exit 0
fi

# does the sate bucket exsist?
created=$(gsutil ls -p ${google_project_id} | grep ${bucket_name} | wc -l)
if [ ${created} == 0 ]; then
    create_bucket_and_migrate_state
    # create backend.tf for infra
else
    echo "Bucket exsists and created $terraform_dir/backend.tf"
fi
create_backend_tf $terraform_dir "netbox-infra"