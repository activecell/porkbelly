class CreateParsedPtHistoryTracks < ActiveRecord::Migration
  def self.up
    create_table :pt_history_tracks do |t|
      t.column :story_type	 , :text
      t.column :estimate	 , :text
      t.column :current_state	 , :text
      t.column :description	 , :text
      t.column :name	 , :string
      t.column :requested_by	 , :string
      t.column :owned_by	 , :string
      t.column :labels	 , :text
      t.column :note_id	 , :string
      t.column :story_id	 , :string	 , :null => false
      t.column :activity_id	 , :string	 , :null => false
      t.timestamps
    end
  end

  def self.down
      drop_table :pt_history_tracks
  end
end

