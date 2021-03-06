#!/bin/bash

readonly script_name=${0##*/}

function trap_failure {
   echo "Failed at: $script_name:$1"
   exit 1
}

trap 'trap_failure $LINENO' ERR
set -eu

do_continue_automatically=False

while getopts "y" o; do
    case "${o}" in
        y)
            do_continue_automatically=True
            ;;
    esac
done

if [ -z "$TRANSITLAND_TOKEN" ]; then
    echo "No TRANSITLAND_TOKEN environment variable set"
    exit 1
fi

if [ -z "$TRANSITLAND_ENV" ]; then
    echo "No TRANSITLAND_ENV environment variable set"
    exit 1
fi

if [ $do_continue_automatically == False ]; then
echo "This is a destructive operation.  The database will have been setup when the AMI was built, this does not need to be run again unless you intend to clear all operators, feeds, routes and stops"
echo "Do you want to continue? yes/no"
read do_continue
fi

if [[ $do_continue_automatically == True ]] || [[ "$do_continue" == "y" ]]  || [[ "$do_continue" == "yes" ]]; then
  docker-compose run app bash ./wait-for-it.sh -h db -p 5432 -- bundle exec rake db:drop db:create db:setup;
  exit 0;
else
  echo "Not continuing."
  exit 0;
fi
