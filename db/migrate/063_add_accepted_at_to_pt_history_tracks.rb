class AddAcceptedAtToPtHistoryTracks < ActiveRecord::Migration
  def self.up
    add_column :pt_history_tracks, :accepted_at, :string

  end
  def self.down
    remove_column :pt_history_tracks, :accepted_at
  end
end

