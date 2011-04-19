class CreateParsedPtActivities < ActiveRecord::Migration
  def self.up
    create_table :pt_activities do |t|
      t.column :target_id	 , :string,	:null => false
      t.column :version	 , :string
      t.column :event_type	 , :string
      t.column :occurred_at	 , :string
      t.column :author	 , :string
      t.column :project_id	 , :string,	:null => false
      t.column :description	 , :string
      t.timestamps
    end
  end

  def self.down
    drop_table :pt_activities
  end
end

