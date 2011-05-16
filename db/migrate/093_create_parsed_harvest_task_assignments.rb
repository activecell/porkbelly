class CreateParsedHarvestTaskAssignments < ActiveRecord::Migration
  def self.up
    create_table :harvest_task_assignments do |t|
      t.column	:billable	, :string	
      t.column	:srv_created_at	, :string	
      t.column	:task_id	, :string	
      t.column	:project_id	, :string	
      t.column	:srv_updated_at	, :string	
      t.column	:hourly_rate	, :string	
      t.column	:target_id	, :string	,:null => false
      t.column	:deactivated	, :string	
      t.column	:budget	, :string	
      t.column	:estimate	, :string	
      t.timestamps
    end
  end

  def self.down
    drop_table :harvest_task_assignments
  end
end

