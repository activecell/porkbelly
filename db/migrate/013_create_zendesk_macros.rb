class CreateZendeskMacros < ActiveRecord::Migration
  def self.up
    create_table :zendesk_macros do |t|
      t.column :request_url, :string, :null => false
      t.column :content, :text, :null => false
      t.column :format, :string, :null => false
      t.column :credential, :string, :null => false
      t.column :target_id, :integer, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :zendesk_macros
  end
end
