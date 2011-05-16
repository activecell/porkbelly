class CreateParsedHarvestUsers < ActiveRecord::Migration
  def self.up
    create_table :harvest_users do |t|
      t.column :first_timer , :string 
      t.column :srv_created_at , :string 
      t.column :has_access_to_all_future_projects , :string 
      t.column :preferred_approval_screen , :string 
      t.column :preferred_project_status_reports_screen , :string 
      t.column :wants_newsletter , :string 
      t.column :twitter_username , :string 
      t.column :default_expense_category_id , :string 
      t.column :default_task_id , :string 
      t.column :default_time_project_id , :string 
      t.column :is_contractor , :string 
      t.column :preferred_entry_method , :string 
      t.column :srv_updated_at , :string 
      t.column :target_id , :string ,:null => false
      t.column :timezone , :string 
      t.column :duplicate_timesheet_wants_notes , :string 
      t.column :is_admin , :string 
      t.column :opensocial_identifier , :string 
      t.column :cache_version , :string 
      t.column :default_hourly_rate , :string 
      t.column :is_active , :string 
      t.column :last_name , :string 
      t.column :wants_timesheet_duplication , :string 
      t.column :default_expense_project_id , :string 
      t.column :email_after_submit , :string 
      t.column :telephone , :string 
      t.column :department , :string 
      t.column :identity_url , :string 
      t.column :email , :string 
      t.column :first_name , :string 
      t.timestamps
    end
  end

  def self.down
    drop_table :harvest_users
  end
end

