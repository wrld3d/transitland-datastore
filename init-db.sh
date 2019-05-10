#!/bin/bash

readonly script_name=${0##*/}

function trap_failure {
   echo "Failed at: $script_name:$1"
   exit 1
}

trap 'trap_failure $LINENO' ERR
set -eu

echo "This is a destructive operation.  The database will have been setup when the AMI was built, this does not need to be run again unless you intend to clear all operators, feeds, routes and stops"
echo "Do you want to continue? yes/no"

read do_continue
if [[ "$do_continue" == "y" ]]  || [[ "$do_continue" == "yes" ]]; then
  rm -rf postgres-data/
  docker-compose run app bash ./wait-for-it.sh -h db -p 5432 -- bundle exec rake db:drop db:create db:setup;
  exit 0;
else
  echo "Not continuing."
  exit 0;
fi
