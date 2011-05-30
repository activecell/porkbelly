class CreateParsedGaProfiles < ActiveRecord::Migration
  def self.up
    create_table :ga_profiles do |t|
      t.column	:title	,:string
      t.column	:account_id	,:string
      t.column	:profileId	,:string
      t.timestamps
      
    end
  end

  def self.down
    drop_table :ga_profiles
  end
end

