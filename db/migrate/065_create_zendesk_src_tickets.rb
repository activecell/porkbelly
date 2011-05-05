class CreateZendeskSrcTickets < ActiveRecord::Migration
  def self.up
    create_table :zendesk_src_tickets do |t|
      t.column :request_url, :string, :null => false
      t.column :content, :text, :null => false
      t.column :format, :string, :null => false
      t.column :credential, :string, :null => false
      t.column :target_id, :string, :null => false
      t.column :subdomain, :string, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :zendesk_src_tickets
  end
end

