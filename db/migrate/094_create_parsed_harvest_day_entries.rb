class CreateParsedHarvestDayEntries < ActiveRecord::Migration
  def self.up
    create_table :harvest_day_entries do |t|
      t.column	:target_id	, :string	,:null => false
      t.column	:spent_at	, :string	
      t.column	:user_id	, :string	
      t.column	:client	, :string	
      t.column	:project_id	, :string	
      t.column	:srv_project	, :string	
      t.column	:task_id	, :string	
      t.column	:srv_task	, :string	
      t.column	:hours	, :string	
      t.column	:notes	, :string	
      t.column	:srv_created_at	, :string	
      t.column	:srv_updated_at	, :string	
      t.column	:timer_started_at	, :string	
      t.column	:for_day	, :string	
      t.timestamps
    end
  end

  def self.down
    drop_table :harvest_day_entries
  end
end

