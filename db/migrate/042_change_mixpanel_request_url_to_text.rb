class ChangeMixpanelRequestUrlToText < ActiveRecord::Migration
  def self.up    
    [:mixpanel_events, :mixpanel_event_properties, :mixpanel_funnels, 
          :mixpanel_funnel_properties].each do |table_name|
      change_table table_name do |t|
        t.change :request_url, :text
      end
    end
  end
end
