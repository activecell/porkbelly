class CreateParsedPtIterationsStories < ActiveRecord::Migration
  def self.up
    create_table :pt_iterations_stories do |t|
      t.column :iteration_id, :string, :null => false
      t.column :story_id, :string, :null => false
      t.timestamps
    end
  end
  def self.down
    drop_table :pt_iterations_stories
  end
end

