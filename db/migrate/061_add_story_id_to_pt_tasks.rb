class AddStoryIdToPtTasks < ActiveRecord::Migration
  def self.up
    add_column :pt_tasks, :story_id, :string

  end
  def self.down
    remove_column :pt_tasks, :story_id
  end
end

