class CreateParsedPtStories < ActiveRecord::Migration
  def self.up
    create_table :pt_stories do |t|
      t.column :target_id	 , :string	, :null => false
      t.column :project_id 	 , :string	, :null => false
      t.column :story_type	 , :string
      t.column :url	 , :string
      t.column :estimate	 , :integer
      t.column :current_state	 , :string
      t.column :description	 , :string
      t.column :name	 , :string
      t.column :requested_by	 , :string
      t.column :owned_by	 , :string
      t.column :srv_created_at	 , :string
      t.column :srv_updated_at	 , :string
      t.column :labels	 , :string
      t.timestamps
    end
  end

  def self.down
    drop_table :pt_stories
  end
end

