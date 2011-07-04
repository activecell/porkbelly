class CreateParsedMixpanelFunnelSteps < ActiveRecord::Migration
  def self.up
    create_table :mixpanel_funnel_steps do |t|
      t.column	:goal	,:text
      t.column	:srv_count	,:text
      t.column	:overall_conv_ratio	,:text
      t.column	:step_conv_ratio	,:text
      t.column	:funnel_id	,:string
      t.timestamps
    end
  end

  def self.down
    drop_table :mixpanel_funnel_steps
  end
end

