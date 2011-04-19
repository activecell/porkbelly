class CreateParsedPtStoriesNotes < ActiveRecord::Migration
  def self.up
    create_table :pt_stories_notes do |t|
      t.column :note_id, :string, :null => false
      t.column :story_id, :string, :null => false
      t.timestamps
    end
  end
  def self.down
    drop_table :pt_stories_notes
  end
end

