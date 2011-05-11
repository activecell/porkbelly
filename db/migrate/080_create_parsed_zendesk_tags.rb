class CreateParsedZendeskTags < ActiveRecord::Migration
  def self.up
    create_table :zendesk_tags do |t|
      t.column	:account_id	, :string
      t.column	:target_id	, :string
      t.column	:score	, :string
      t.column	:tag_id	, :string
      t.column	:tag_name	, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :zendesk_tags
  end
end

