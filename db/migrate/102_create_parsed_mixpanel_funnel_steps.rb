class CreateParsedMixpanelFunnelSteps < ActiveRecord::Migration
  def self.up
    create_table :mixpanel_funnel_steps do |t|
      t.column	:goal	,:string
      t.column	:srv_count	,:string
      t.column	:overall_conv_ratio	,:string
      t.column	:step_conv_ratio	,:string
      t.column	:funnel_id	,:string
      t.timestamps
    end
  end

  def self.down
    drop_table :mixpanel_funnel_steps
  end
end

