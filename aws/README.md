# Creating a new AMI
Set the required variables in `packer_variables.json`.  
  - `aws_access_key` is the access key of an account with permission to create EC2 instances.  There has been a group created with this permission - add your account to that group 
  - `aws_secret_key` is the secret key corresponding to the access key.
  - `wrld_transitland_datastore_deployment_key` is a private ssh key with the ability to pull the wrld3d/valhalla repo.  The `transitland-packer.pem` in passwordstate has been added as a deployment key to that repo, but you need to modify the newlines since this is passed as an environment variable to the script
  - `deploy_env` - staging or production
  - `transitland_token` - token used to authenticate API calls

`$ create_transitland_ami.sh` wraps the packer script.  Packer will spin up a clean EC2 isntance, and run `setup_dependencies.sh` on it to install dependencies.  Packer will then shut down the instance, create an AMI from it, and termintate it.

Once complete, launch an instance of the new AMI (the name will be returned by `create_transitland_ami.sh`)
The new instance should be assigned the role `wrld-routing-service-worker` in order to access the s3 stores.
To launch the service, SSH into the new instance and run 
`$ cd ~/transitland-datastore && docker-compose up -d`
This will build and start the transitland service datastore.  The docker-compose.yml is configured to restart when the machine reboots

## To apply changesets (eg adding new operators / feeds)
`$ sh ~/transitland-datastore/import-changesets.sh *timestamp* *operator_1* *operator_2* ...`
Timestamp refers to the timestamped folder on S3 for versions of gtfs
Operators is a space separated list of operators.  This also makes up part of the S3 url and is in the format [geohash]-[unique_name_within_geohash]

## To rebuild routes from new gtfs data
`$ sh ~/transitland-datastore/import-gtfs.sh *timestamp* *operator_1* *operator_2* ...`
Timestamp refers to the timestamped folder on S3 for versions of gtfs
Operators is a space separated list of operators.  This also makes up part of the S3 url and is in the format [geohash]-[unique_name_within_geohash]

## To clear the database (remove all operators and feeds and start from a clean datastore)
./init-db.sh