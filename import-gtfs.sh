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
    echo "This script fetches gtfs data from S3 and imports it into transitland." >&2
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
readonly gtfs_path=./gtfs

readonly gtfs_bucket="s3://wrld-routing-service/transitland-$TRANSITLAND_ENV-gtfs/$timestamp"
echo "Downloading gtfs data..."
for operator in $operators
do
    echo "Downloading gtfs for $operator from $gtfs_bucket/$operator.zip"
    aws s3 cp "$gtfs_bucket/$operator.zip" "$gtfs_path"
done
echo "Downloaded gtfs data"

docker exec -it $(docker ps --filter "name=app" -q) /bin/bash /app/worker-scripts/import-gtfs.sh $TRANSITLAND_TOKEN $operators
exit 0