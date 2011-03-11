class CreateMixpanelEvents < ActiveRecord::Migration
  def self.up
    create_table :mixpanel_events do |t|
      t.column :target_id , :string
      t.column :content, :text, :null => false
      t.column :credential, :string, :null => false      
      t.column :request_url, :text
      t.column :format, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :mixpanel_events
  end
end
