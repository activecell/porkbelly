class CreateMixpanelEvents < ActiveRecord::Migration
  def self.up
    create_table :mixpanel_events do |t|
      t.column :content, :string, :null => false
      t.column :credential, :string, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :mixpanel_events
  end
end
