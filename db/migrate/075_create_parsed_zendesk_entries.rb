class CreateParsedZendeskEntries < ActiveRecord::Migration
  def self.up
    create_table :zendesk_entries do |t|
      t.column	:body	, :text
      t.column	:srv_created_at	, :string
      t.column	:current_tags	, :string
      t.column	:flag_type_id	, :string
      t.column	:forum_id	, :string
      t.column	:hits	, :string
      t.column	:target_id	, :string	,:null => false
      t.column	:is_highlighted	, :string
      t.column	:is_locked	, :string
      t.column	:is_pinned	, :string
      t.column	:is_public	, :string
      t.column	:organization_id	, :string
      t.column	:position	, :string
      t.column	:posts_count	, :string
      t.column	:submitter_id	, :string
      t.column	:title	, :string
      t.column	:srv_updated_at	, :string
      t.column	:votes_count	, :string
     t.timestamps
    end
  end

  def self.down
    drop_table :zendesk_entries
  end
end

