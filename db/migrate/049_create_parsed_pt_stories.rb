class CreateParsedPtStories < ActiveRecord::Migration
  def self.up
    create_table :pt_stories do |t|
      t.column :target_id	 , :string	, :null => false
      t.column :project_id 	 , :string	, :null => false
      t.column :story_type	 , :string
      t.column :url	 , :string
      t.column :estimate	 , :text
      t.column :current_state	 , :text
      t.column :description	 , :text
      t.column :name	 , :text
      t.column :requested_by	 , :string
      t.column :owned_by	 , :string
      t.column :srv_created_at	 , :string
      t.column :srv_updated_at	 , :string
      t.column :labels	 , :text
      t.timestamps
    end
  end

  def self.down
    drop_table :pt_stories
  end
end

