#!/bin/bash
# run this locally to create an AMI which can then be used to spin up your ec2 instance proper

set -e
set -u

readonly script_name=${0##*/}

trap_failure() {
    echo "Error: $script_name: $1" >&2
    exit 1
}

trap 'trap_failure $LINENO' ERR

readonly packer_template="packer_template.json"
readonly packer_variables="packer_variables.json"

echo "running packer to build image from configuration: '$packer_template' using variables '$packer_variables' ..."

packer validate "$packer_template"

packer build -var-file "$packer_variables" "$packer_template"

echo "AMI build completed. AMI id:"

readonly manifest="manifest.json"
cat "$manifest" | jq -r .builds[0].artifact_id | cut -d':' -f2

rm -rf "$manifest"