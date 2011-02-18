class CreateZendeskGroups < ActiveRecord::Migration
  def self.up
    create_table :zendesk_groups do |t|
			t.column :request_url, :string, :null => false
      t.column :content, :string, :null => false
			t.column :format, :string, :null => false
      t.column :credential, :string, :null => false
			
      t.timestamps
    end
  end

  def self.down
    drop_table :zendesk_groups
  end
end
