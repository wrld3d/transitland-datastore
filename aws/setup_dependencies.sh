#!/bin/bash

set -e
set -u

echo "Starting setup_dependencies.sh" 

sudo yum update -y

sudo yum install git -y

echo -e "$GITHUB_DEPLOYMENT_KEY" > ~/.ssh/id_rsa

sudo chmod 600 ~/.ssh/id_rsa

ssh-keyscan -H github.com >> ~/.ssh/known_hosts
echo export TRANSITLAND_ENV="$TRANSITLAND_ENV" >> ~/.bash_profile
echo export TRANSITLAND_TOKEN="$TRANSITLAND_TOKEN" >> ~/.bash_profile

sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ${USER}

echo "Downloading release of docker-compose..."
sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo gpasswd -a ${USER} docker

sudo service docker restart

# There should be no need to configure git users as we have set a github deployment key
git clone git@github.com:wrld3d/transitland-datastore.git

pushd transitland-datastore
cp "./env/$TRANSITLAND_ENV" env/default
echo -e "TRANSITLAND_DATASTORE_AUTH_TOKEN=$TRANSITLAND_TOKEN" >> env/default
popd

echo "Completed setup_dependencies.sh" 

# Reboot to apply new user groups to allow docker commands.  Other approaches (source, separate scripts) have failed
sudo reboot