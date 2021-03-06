class AddTypeToFeeds < ActiveRecord::Migration
  def change
    add_column :current_feeds, :type, :string, index: true
    add_column :old_feeds, :type, :string, index: true
    add_column :current_feeds, :authorization, :hstore
    add_column :old_feeds, :authorization, :hstore
    add_column :current_feeds, :urls, :hstore
    add_column :old_feeds, :urls, :hstore
    add_index :current_feeds, :urls
    add_index :current_feeds, :authorization
  end
end
