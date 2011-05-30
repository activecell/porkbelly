class CreateZendeskSrcViews < ActiveRecord::Migration
  def self.up
    create_table :zendesk_src_views do |t|
      t.column :request_url, :string, :null => false
      t.column :content, :text, :null => false
      t.column :format, :string, :null => false
      t.column :credential, :string, :null => false
      t.column :target_id, :integer, :null => false
      t.column :per_page, :integer, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :zendesk_src_views
  end
end
