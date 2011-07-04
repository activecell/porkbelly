class CreateParsedPtProjects < ActiveRecord::Migration
  def self.up
    create_table :pt_projects do |t|
      t.column :target_id	 , :string	 , :null => false
      t.column :name	 , :text
      t.column :iteration_length	 , :integer
      t.column :week_start_day	 , :string
      t.column :point_scale	 , :string
      t.column :account	 , :string
      t.column :first_iteration_start_time	 , :text
      t.column :current_iteration_number	 , :text
      t.column :enable_tasks	 , :text
      t.column :velocity_scheme	 , :string
      t.column :current_velocity	 , :text
      t.column :initial_velocity	 , :text
      t.column :number_of_done_iterations_to_show	 , :text
      t.column :labels	 , :text
      t.column :last_activity_at	 , :text
      t.column :allow_attachments	 , :text
      t.column :public	 , :string
      t.column :use_https	 , :text
      t.column :bugs_and_chores_are_estimatable	 , :text
      t.column :commit_mode	 , :text
      t.timestamps
    end
  end

  def self.down
    drop_table :pt_projects
  end
end

