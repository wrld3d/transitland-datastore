# == Schema Information
#
# Table name: gtfs_agencies
#
#  id              :integer          not null, primary key
#  agency_id       :string
#  agency_name     :string           not null
#  agency_url      :string           not null
#  agency_timezone :string           not null
#  agency_lang     :string
#  agency_phone    :string
#  agency_fare_url :string
#  agency_email    :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  feed_version_id :integer          not null
#  entity_id       :integer
#
# Indexes
#
#  index_gtfs_agencies_on_agency_id        (agency_id)
#  index_gtfs_agencies_on_agency_name      (agency_name)
#  index_gtfs_agencies_on_entity_id        (entity_id)
#  index_gtfs_agencies_on_feed_version_id  (feed_version_id)
#  index_gtfs_agencies_unique              (feed_version_id,agency_id) UNIQUE
#

class GTFSAgency < ActiveRecord::Base
  include GTFSEntity
  has_many :routes, class_name: 'GTFSRoute', foreign_key: 'agency_id'
  has_many :trips, through: :routes
  has_many :stops, -> { distinct }, through: :trips
  has_many :shapes, -> { distinct }, through: :trips
  has_many :stop_times, through: :trips
  belongs_to :feed_version
  belongs_to :entity, class_name: 'Operator'
  validates :feed_version, presence: true, unless: :skip_association_validations
  validates :agency_name, presence: true
  validates :agency_url, presence: true
  validates :agency_timezone, presence: true
end
