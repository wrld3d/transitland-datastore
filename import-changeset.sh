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
    echo "This script updates the transitland service with changesets from an S3 store." >&2
    echo "" >&2
    echo "Usage:  ${script_name} timestamp operators" >&2
    echo "e.g.    ${script_name} 2019 9q9-funbus thr-dubairta" >&2
    echo "" >&2
}

if [ -z "$TRANSITLAND_TOKEN" ]; then
    echo "No TRANSITLAND_TOKEN environment variable set"
    exit 1
fi

if [ -z "$TRANSITLAND_ENV" ]; then
    echo "No TRANSITLAND_ENV environment variable set"
    exit 1
fi

if [ -z "$1" ] || [ -z "$2" ]; then
    print_usage
    exit 1
fi

readonly timestamp=$1
readonly operators=$2
readonly changeset_path=./db/sample-changesets
readonly gtfs_path=./gtfs

readonly changeset_bucket="s3://wrld-routing-service/transitland-$TRANSITLAND_ENV-changesets"
readonly gtfs_bucket="s3://wrld-routing-service/transitland-$TRANSITLAND_ENV-gtfs/$timestamp"
echo "Downloading data..."
for operator in $operators
do
    echo "Downloading changeset for $operator from $changeset_bucket/$operator.json"
    aws s3 cp "$changeset_bucket/$operator.json" "$changeset_path"
    echo "Downloading gtfs for $operator from $gtfs_bucket/$operator.zip"
    aws s3 cp "$gtfs_bucket/$operator.zip" "$gtfs_path"
done
echo "Downloaded data"

docker exec -it $(docker ps --filter "name=app" -q) /bin/bash /app/worker-scripts/import-changeset.sh $TRANSITLAND_TOKEN $operators
exit 0