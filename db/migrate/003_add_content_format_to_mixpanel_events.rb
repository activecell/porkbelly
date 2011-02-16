class AddContentFormatToMixpanelEvents < ActiveRecord::Migration  
  def self.up
    add_column :mixpanel_events, :content_format, :string
  end

  def self.down
    remove_column :mixpanel_events, :content_format
  end
end
