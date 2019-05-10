# Transitland
GTFS zip file needs the data in the root of the zip
Ids of feeds, operators and routes are defined by https://transit.land/documentation/onestop-id-scheme/
Basically: [type]-[geohash]-[unique_name_within_geohash]
where type is one of f, o, s, r
  * f => feed
  * o => operator
  * s => stop
  * r => route

## Setting up a clean database instance
THe following sets up a clean postgis instance.  This is done automatically by the packer script via ./init-db.sh and shouldn't need to be done manually.  The steps are included only for posterity.
`$ cd ~/transitland-datastore`
`$ bundle exec rake db:drop`
`$ bundle exec rake db:create`
`$ bundle exec rake db:setup`

## Applying changesets
./import-changeset.sh *timestamp* *operator_list*
Fetches the changeset & gtfs file from S3 and uses the REST API to trigger the sidekiq worker to import the changeset
Argument 1 is a timestamp that makes up part of the S3 url for different versions of the feed. 
Argument 2 is the operator - this also makes up part of the S3 url and is in the format [geohash]-[unique_name_within_geohash]

The following manual steps are included for posterity.  This can be done via the above script and shouldn't need to be run via the API or rake.  
See ./worker-scripts//import-changeset.sh for examples of the API calls.  
The command is included for posterity.
`bundle exec rake db:load:sample_changesets`

## Feed ingestion
./import-gtfs.sh *timestamp* *operator_list*
Fetches the gtfs files from S3 and uses the REST API to trigger the feed eater
Argument 1 is a timestamp that makes up part of the S3 url for different versions of the feed. 
Argument 2 is the operator - this also makes up part of the S3 url and is in the format [geohash]-[unique_name_within_the_geohash]

The following manual steps are included for posterity.  This can be done via the above script and shouldn't need to be run via the API or rake.
See ./worker-scripts/import-gtfs.sh for examples of the API calls.  
Argument 1 is the feed ID.  This is made up of three parts - f for feed, a geohash of the area, and a name
Argument 2 means import everything - operator, routes, trips, stops, and schedules.
`bundle exec rake enqueue_feed_eater_worker[f-9q9-bart,'',2]`

## Launching Sidekiq
Sidekiq is containerised to launch when the app is ready, but this is the command to launch it manually
`LD_LIBRARY_PATH=/usr/local/lib bundle exec sidekiq`

## Launching the web service
This is managed by the app docker container and shouldn't need run manually.  The command is included for posterity.
`bundle exec rails server -p 3000 -b 0.0.0.0`

## Troubleshooting
If the process starts to fail randomly, try clearing the redis keys and starting again.
You can do this by destroying the docker container.  The following commands are included for posterity.
Shut down sidekiq (and any other processes), and in the app container run
`redis-cli`
`FLUSHALL`
`keys *`
You should see the empty set.
Relaunch the redis & sidekiq containers and resubmit the job
