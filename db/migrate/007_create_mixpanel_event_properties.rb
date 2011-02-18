class CreateMixpanelEventProperties < ActiveRecord::Migration
  def self.up
    create_table :mixpanel_event_properties do |t|
      t.column :content, :text, :null => false      
      t.column :credential, :string, :null => false
      t.column :format, :string
      t.column :request_url, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :mixpanel_event_properties
  end
end
