class CreateParsedMixpanelEvents < ActiveRecord::Migration
  def self.up
    create_table :mixpanel_events do |t|
      t.column	:name	,:string
      t.column	:at_date	,:string
      t.column	:srv_count	,:string
      t.column  :token  ,:string
      t.timestamps
    end
  end

  def self.down
    drop_table :mixpanel_events
  end
end

