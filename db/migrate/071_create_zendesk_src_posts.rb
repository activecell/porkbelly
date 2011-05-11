class CreateZendeskSrcPosts < ActiveRecord::Migration
  def self.up
    create_table :zendesk_src_posts do |t|
      t.column :content, :text, :null => false
      t.column :format, :string, :null => false
      t.column :credential, :string, :null => false
      t.column :target_id, :string, :null => false
      t.column :entry_id, :string, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :zendesk_src_posts
  end
end

