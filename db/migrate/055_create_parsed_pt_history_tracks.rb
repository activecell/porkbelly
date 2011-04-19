class CreateParsedPtHistoryTracks < ActiveRecord::Migration
  def self.up
    create_table :pt_history_tracks do |t|
      t.column :story_type	 , :string
      t.column :estimate	 , :string
      t.column :current_state	 , :string
      t.column :description	 , :string
      t.column :name	 , :string
      t.column :requested_by	 , :string
      t.column :owned_by	 , :string
      t.column :labels	 , :string
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

