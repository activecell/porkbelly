class RenameParamsInMixpanelEvents < ActiveRecord::Migration  
  def self.up
    rename_column :mixpanel_events, :params, :request_url
  end

  def self.down
    #remove_column :mixpanel_events, :request_url
  end
end
