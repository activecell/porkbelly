class CreateGaGoals < ActiveRecord::Migration
  def self.up
    create_table :ga_goals do |t|
      t.column :profile_id, :integer, :null => false
      t.column :name, :string, :null => false
      t.column :entry, :text, :null => false
      t.column :content, :text
      t.column :credential, :string, :null => false
      t.column :request_url, :string
      t.column :format, :string

      t.timestamps
    end
  end

  def self.down
    drop_table :ga_goals
  end
end
