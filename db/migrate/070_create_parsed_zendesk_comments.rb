class CreateParsedZendeskComments < ActiveRecord::Migration
  def self.up
    create_table :zendesk_comments do |t|
      t.column	:author_id,:string
      t.column	:created_at,:string
      t.column	:is_public,:string
      t.column	:type_ele,:string
      t.column	:value,:text
      t.column	:via_id,:string
      t.column  :token,:string, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :zendesk_comments
  end
end

