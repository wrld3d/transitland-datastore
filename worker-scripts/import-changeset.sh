#!/bin/bash

readonly script_name=${0##*/}

function trap_failure {
   echo "Failed at: $script_name:$1"
   exit 1
}

trap 'trap_failure $LINENO' ERR
set -eu

function print_usage
{
    echo "" >&2
    echo "This script imports changesets to transitland (eg adding new operators) via the REST API." >&2
    echo "" >&2
    echo "Usage:  ${script_name} transitland_token operators" >&2
    echo "e.g.    ${script_name} 01234567890 9q9-funbus thr-dubairta" >&2
    echo "" >&2
}

if [ -z "$1" ]; then
    print_usage
    exit 1
fi

readonly transitland_token=$1
readonly operators=$2

readonly changeset_path=./db/sample-changesets

for operator in $operators
do
    echo "Fetching changeset for $operator"
    post_changeset_json=$(curl -s -X POST -d "@$changeset_path/$operator.json" -H "Content-Type: application/json" http://localhost:3000/api/v1/changesets)
    if [ -z "$post_changeset_json" ]; then
        "Failed to post changeset"
        exit 1
    fi

    id=$(echo $post_changeset_json | python3 -c "import sys, json; print(json.load(sys.stdin)['id'])")
    if [ -z "$post_changeset_json" ]; then
        "Changeset response $post_changeset_json invalid: Does not contain changeset id"
        exit 1
    fi
    echo "Checking changeset $id"
    check_changeset_json=$(curl -s -X POST -H "Authorization: Token token=$transitland_token" "http://localhost:3000/api/v1/changesets/$id/check")
    check_value=$(echo $check_changeset_json | python3 -c "import sys, json; print(json.load(sys.stdin)['trialSucceeds'])")
    if [ -z $check_value ]; then
        "Changeset trial response $check_changeset_json invalid: Does not contain trialSucceeds"
        exit 1
    fi
    if [ $check_value != True ]; then
        "Changeset trial failed with $check_changeset_json"
        exit 1
    fi

    echo "Applying changeset $id"
    apply_changeset_json=$(curl -s -X POST -H "Authorization: Token token=$transitland_token" "http://localhost:3000/api/v1/changesets/$id/apply")
    apply_value=$(echo $apply_changeset_json | python3 -c "import sys, json; print(json.load(sys.stdin)['applied'][0])")
    if [ -z $apply_value ]; then
        "Apply changeset response $check_changeset_json invalid: Does not contain applied"
        exit 1
    fi
    if [ $apply_value != True ]; then
        "Apply changeset response failed with $check_changeset_json"
        exit 1
    fi
done