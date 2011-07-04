class CreateParsedMixpanelFunnelPropertyValues < ActiveRecord::Migration
  def self.up
    create_table :mixpanel_funnel_property_values do |t|
      t.column	:name	,:text
      t.column	:end	,:string
      t.column	:start	,:string
      t.column	:total_visitors	,:string
      t.column	:funnel_property_id	,:string
      t.timestamps
    end
  end

  def self.down
    drop_table :mixpanel_funnel_property_values
  end
end

