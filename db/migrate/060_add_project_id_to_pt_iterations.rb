class AddProjectIdToPtIterations < ActiveRecord::Migration
  def self.up
    add_column :pt_iterations, :project_id, :string

  end
  def self.down
    remove_column :pt_iterations, :project_id, :string
  end
end

