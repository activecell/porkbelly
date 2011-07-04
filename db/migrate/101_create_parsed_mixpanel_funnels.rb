class CreateParsedMixpanelFunnels < ActiveRecord::Migration
  def self.up
    create_table :mixpanel_funnels do |t|
      t.column	:at_date	,:string
      t.column	:name	,:text
      t.column	:completion	,:text
      t.column	:starting_amount	,:text
      t.column	:worst	,:text
      t.column	:token	,:string
      t.timestamps
    end
  end

  def self.down
    drop_table :mixpanel_funnels
  end
end

