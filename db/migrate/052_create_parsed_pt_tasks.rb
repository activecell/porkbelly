class CreateParsedPtTasks < ActiveRecord::Migration
  def self.up
    create_table :pt_tasks do |t|
      t.column :target_id	 , :string	 , :null => false
      t.column :description	 , :string
      t.column :position	 , :string
      t.column :complete	 , :string
      t.column :srv_created_at	 , :string
      t.timestamps
    end
  end

  def self.down
    drop_table :pt_tasks
  end
end

