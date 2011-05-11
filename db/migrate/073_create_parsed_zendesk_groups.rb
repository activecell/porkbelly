class CreateParsedZendeskGroups < ActiveRecord::Migration
  def self.up
    create_table :zendesk_groups do |t|
      t.column	:srv_created_at	, :string
      t.column	:target_id	, :string	,:null => false
      t.column	:is_active	, :string
      t.column	:name	, :string
      t.column	:srv_updated_at	, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :zendesk_groups
  end
end

