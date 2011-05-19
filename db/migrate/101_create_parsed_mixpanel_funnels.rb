class CreateParsedMixpanelFunnels < ActiveRecord::Migration
  def self.up
    create_table :mixpanel_funnels do |t|
      t.column	:at_date	,:string
      t.column	:name	,:string
      t.column	:completion	,:string
      t.column	:starting_amount	,:string
      t.column	:worst	,:string
      t.column	:token	,:string
      t.timestamps
    end
  end

  def self.down
    drop_table :mixpanel_funnels
  end
end

