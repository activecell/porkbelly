class CreateParsedMixpanelFunnelProperties < ActiveRecord::Migration
  def self.up
    create_table :mixpanel_funnel_properties do |t|
      t.column	:name	,:string
      t.column	:date	,:string
      t.column	:funnel_id	,:string
      t.column	:steps	,:string
      t.column	:values	,:string
      t.timestamps
    end
  end

  def self.down
    drop_table :mixpanel_funnel_properties
  end
end

