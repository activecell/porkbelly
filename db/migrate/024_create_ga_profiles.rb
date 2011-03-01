class CreateGaProfiles < ActiveRecord::Migration
  def self.up
    create_table :ga_profiles do |t|
      t.column :content, :text, :null => false
      t.column :credential, :string, :null => false      
      t.column :request_url, :string
      t.column :format, :string

      t.timestamps
    end
  end

  def self.down
    drop_table :ga_profiles
  end
end
