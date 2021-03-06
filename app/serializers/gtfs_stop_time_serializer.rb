# == Schema Information
#
# Table name: gtfs_stop_times
#
#  id                       :integer          not null, primary key
#  arrival_time             :integer          not null
#  departure_time           :integer          not null
#  stop_sequence            :integer          not null
#  stop_headsign            :string
#  pickup_type              :integer
#  drop_off_type            :integer
#  shape_dist_traveled      :float
#  timepoint                :integer
#  interpolated             :integer          default(0), not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  feed_version_id          :integer          not null
#  trip_id                  :integer          not null
#  stop_id                  :integer          not null
#  destination_id           :integer
#  destination_arrival_time :integer
#
# Indexes
#
#  index_gtfs_stop_times_on_arrival_time              (arrival_time)
#  index_gtfs_stop_times_on_departure_time            (departure_time)
#  index_gtfs_stop_times_on_destination_arrival_time  (destination_arrival_time)
#  index_gtfs_stop_times_on_destination_id            (destination_id)
#  index_gtfs_stop_times_on_feed_version_id           (feed_version_id)
#  index_gtfs_stop_times_on_stop_id                   (stop_id)
#  index_gtfs_stop_times_on_trip_id                   (trip_id)
#  index_gtfs_stop_times_unique                       (feed_version_id,trip_id,stop_sequence) UNIQUE
#

class GTFSStopTimeSerializer < GTFSEntitySerializer
    attributes :stop_sequence, 
                :stop_headsign, 
                :pickup_type, 
                :drop_off_type, 
                :shape_dist_traveled, 
                :timepoint, 
                :interpolated, 
                :trip_id, 
                :stop_id, 
                :destination_id,
                :arrival_time,
                :departure_time,
                :destination_arrival_time

    def arrival_time
        GTFS::WideTime.new(object.arrival_time).to_s
    end

    def departure_time
        GTFS::WideTime.new(object.departure_time).to_s
    end

    def destination_arrival_time
        GTFS::WideTime.new(object.destination_arrival_time).to_s if object.destination_arrival_time
    end
end
  
