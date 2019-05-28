#!/bin/bash

set -e
set -u

echo "Starting setup_db.sh" 

pushd transitland-datastore
sh ./init-db.sh -y
popd

echo "Completed setup_db.sh"