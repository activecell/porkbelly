class CreateGaAccounts < ActiveRecord::Migration
  def self.up
    create_table :ga_accounts do |t|
      t.column :account_id, :integer, :null => false
      t.column :content, :text
      t.column :credential, :string, :null => false
      t.column :request_url, :string
      t.column :format, :string

      t.timestamps
    end
  end

  def self.down
    drop_table :ga_accounts
  end
end
