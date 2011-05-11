
class CreateParsedZendeskPosts < ActiveRecord::Migration
  def self.up
    create_table :zendesk_posts do |t|
      t.column	:account_id	, :string
      t.column	:body	, :text
      t.column	:srv_created_at	, :string
      t.column	:entry_id	, :string
      t.column	:forum_id	, :string
      t.column	:target_id	, :string
      t.column	:is_informative	, :string
      t.column	:srv_updated_at	, :string
      t.column	:user_id	, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :zendesk_posts
  end
end

