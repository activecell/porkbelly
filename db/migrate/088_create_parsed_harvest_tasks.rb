class CreateParsedHarvestTasks < ActiveRecord::Migration
  def self.up
    create_table :harvest_tasks do |t|
      t.column	:name	, :string	
      t.column	:srv_created_at	, :string	
      t.column	:billable_by_default	, :string	
      t.column	:is_default	, :string	
      t.column	:srv_updated_at	, :string	
      t.column	:target_id	, :string	,:null => false
      t.column	:cache_version	, :string	
      t.column	:deactivated	, :string	
      t.column	:default_hourly_rate	, :string	
      t.timestamps
    end
  end

  def self.down
    drop_table :harvest_tasks
  end
end

