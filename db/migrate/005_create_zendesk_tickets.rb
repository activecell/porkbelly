class CreateZendeskTickets < ActiveRecord::Migration
  def self.up
    create_table :zendesk_tickets do |t|
			t.column :request_url, :string, :null => false
      t.column :content, :string, :null => false
			t.column :fortmat, :string, :null => false
      t.column :credential, :string, :null => false
			
      t.timestamps
    end
  end

  def self.down
    drop_table :zendesk_tickets
  end
end
