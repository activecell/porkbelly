class CreateParsedMixpanelEventProperties < ActiveRecord::Migration
  def self.up
    create_table :mixpanel_event_properties do |t|
      t.column	:name	,:string
      t.column	:event_token,:string
      t.column	:value	,:string
      t.column	:at_date	,:string
      t.column	:srv_count	,:string
      t.timestamps
    end
  end

  def self.down
    drop_table :mixpanel_event_properties
  end
end

