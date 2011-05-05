class CreateParsedZendeskViews < ActiveRecord::Migration
  def self.up
    create_table :zendesk_views do |t|
      t.column	:target_id	, :string	,:null => false
      t.column	:is_active	, :string
      t.column	:owner_id	, :string
      t.column	:owner_type	, :string
      t.column	:per_page	, :string
      t.column	:position	, :string
      t.column	:title	, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :zendesk_views
  end
end

