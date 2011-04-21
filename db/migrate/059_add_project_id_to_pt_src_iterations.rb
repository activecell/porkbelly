class AddProjectIdToPtSrcIterations < ActiveRecord::Migration
  def self.up
    add_column :pt_src_iterations, :project_id, :string

  end
  def self.down
    remove_column :pt_src_iterations, :project_id, :string
  end
end

