class CreateParsedMixpanelFunnelPropertySteps < ActiveRecord::Migration
  def self.up
    create_table :mixpanel_funnel_property_steps do |t|
      t.column	:name	,:string
      t.column	:funnel_property_value_id	,:string
      t.column	:best	,:string
      t.column	:srv_count	,:string
      t.timestamps
    end
  end

  def self.down
    drop_table :mixpanel_funnel_property_steps
end

