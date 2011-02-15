class AddParamsToMixpanelEvents < ActiveRecord::Migration  
  def self.up
    add_column :mixpanel_events, :params, :string
  end

  def self.down
    remove_column :mixpanel_events, :params
  end
end
