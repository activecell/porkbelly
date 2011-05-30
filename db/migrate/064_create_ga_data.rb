class CreateGaData < ActiveRecord::Migration
  def self.up
    create_table :ga_data do |t|
      t.column :account_id, :integer, :null => false
      t.column :table_id, :string, :null => false
      t.column :content, :text
      t.column :credential, :string, :null => false
      t.column :request_url, :text
      t.column :format, :string

      t.timestamps
    end
  end

  def self.down
    drop_table :ga_data
  end
end
