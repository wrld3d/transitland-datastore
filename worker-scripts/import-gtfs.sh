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
    echo "This script updates the transitland service with gtfs data." >&2
    echo "" >&2
    echo "Usage:  ${script_name} transitland_token feed_ids" >&2
    echo "e.g.    ${script_name} 01234567890 f-9q9-funbus f-thr-dubairta" >&2
    echo "" >&2
}

if [ -z "$1" ]; then
    print_usage
    exit 1
fi

readonly transitland_token=$1
readonly operators=$2

for operator in $operators
do
    echo "Running feed eater for $operator"

    feed_versions=$(curl "http://localhost:3000/api/v1/feed_versions?feed_onestop_id=f-$operator")
    if [ -z $feed_versions ]; then
        "Failed to get feed versions"
        exit 1
    fi
    latest_version=$(echo $feed_versions | python3 -c "import sys, json; print(json.load(sys.stdin)['feed_versions'][0]['sha1'])")
        if [ -z $latest_version ]; then
        "Failed to extract latest feed version from $feed_versions"
        exit 1
    fi
    if [ $latest_version == "" ]; then
        "Failed to extract latest feed version from $feed_versions (Got empty string)"
        exit 1
    fi

    echo "Latest feed version sha1: $latest_version"

    echo "Launching feed eater"
    curl -s -X POST -H "Authorization: Token token=$transitland_token" "http://localhost:3000/api/v1/webhooks/feed_eater?feed_onestop_id=f-$operator&feed_version_sha1=$latest_version"
done