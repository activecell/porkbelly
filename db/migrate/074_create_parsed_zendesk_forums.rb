class CreateParsedZendeskForums < ActiveRecord::Migration
  def self.up
    create_table :zendesk_forums do |t|
      t.column	:category_id	, :string
      t.column	:description	, :string
      t.column	:display_type_id	, :string
      t.column	:entries_count	, :string
      t.column	:target_id	, :string	,:null => false
      t.column	:is_locked	, :string
      t.column	:name	, :string
      t.column	:organization_id	, :string
      t.column	:position	, :string
      t.column	:translation_locale_id	, :string
      t.column	:srv_updated_at	, :string
      t.column	:use_for_suggestions	, :string
      t.column	:visibility_restriction_id	, :string
      t.column	:is_public 	, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :zendesk_forums
  end
end

