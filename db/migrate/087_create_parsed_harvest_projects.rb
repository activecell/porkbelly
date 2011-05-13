class CreateParsedHarvestProjects < ActiveRecord::Migration
  def self.up
    create_table :harvest_projects do |t|
      t.column :name , :string 
      t.column :over_budget_notified_at , :string 
      t.column :billable , :string 
      t.column :srv_created_at , :string 
      t.column :earliest_record_at , :string 
      t.column :show_budget_to_all , :string 
      t.column :code , :string 
      t.column :cost_budget , :string 
      t.column :notify_when_over_budget , :string 
      t.column :srv_updated_at , :string 
      t.column :cost_budget_include_expenses , :string 
      t.column :fees , :string 
      t.column :highrise_deal_id , :string 
      t.column :latest_record_at , :string 
      t.column :hourly_rate , :string 
      t.column :target_id , :string ,:null => false
      t.column :bill_by , :string 
      t.column :client_id , :string 
      t.column :active_user_assignments_count , :string 
      t.column :cache_version , :string 
      t.column :budget , :string 
      t.column :over_budget_notification_percentage , :string 
      t.column :active , :string 
      t.column :active_task_assignments_count , :string 
      t.column :basecamp_id , :string 
      t.column :budget_by , :string 
      t.column :estimate , :string 
      t.column :estimate_by , :string 
      t.column :notes , :string 
      t.column :hint_earliest_record_at , :string 
      t.column :hint_latest_record_at , :string 
      t.timestamps
    end
  end

  def self.down
    drop_table :harvest_projects
  end
end

