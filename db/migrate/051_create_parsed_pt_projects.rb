class CreateParsedPtProjects < ActiveRecord::Migration
  def self.up
    create_table :pt_projects do |t|
      t.column :target_id	 , :string	 , :null => false
      t.column :name	 , :string
      t.column :iteration_length	 , :integer
      t.column :week_start_day	 , :string
      t.column :point_scale	 , :string
      t.column :account	 , :string
      t.column :first_iteration_start_time	 , :string
      t.column :current_iteration_number	 , :string
      t.column :enable_tasks	 , :string
      t.column :velocity_scheme	 , :string
      t.column :current_velocity	 , :string
      t.column :initial_velocity	 , :string
      t.column :number_of_done_iterations_to_show	 , :string
      t.column :labels	 , :string
      t.column :last_activity_at	 , :string
      t.column :allow_attachments	 , :string
      t.column :public	 , :string
      t.column :use_https	 , :string
      t.column :bugs_and_chores_are_estimatable	 , :string
      t.column :commit_mode	 , :string
      t.timestamps
    end
  end

  def self.down
    drop_table :pt_projects
  end
end

