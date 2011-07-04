class CreateParsedPtTasks < ActiveRecord::Migration
  def self.up
    create_table :pt_tasks do |t|
      t.column :target_id	 , :string	 , :null => false
      t.column :description	 , :text
      t.column :position	 , :text
      t.column :complete	 , :text
      t.column :srv_created_at	 , :string
      t.timestamps
    end
  end

  def self.down
    drop_table :pt_tasks
  end
end

