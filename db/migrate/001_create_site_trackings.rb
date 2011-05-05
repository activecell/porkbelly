class CreateSiteTrackings < ActiveRecord::Migration
  def self.up
    create_table :site_trackings do |t|
      t.column :site, :string, :null => false
      t.column :target, :string, :null => false
      t.column :last_request, :datetime
    end
  end

  def self.down
    drop_table :site_trackings
  end
end

