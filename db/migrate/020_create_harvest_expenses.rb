class CreateHarvestExpenses < ActiveRecord::Migration
  def self.up
    create_table :harvest_expenses do |t|
      t.column :target_id , :string, :null => false
      t.column :content, :text, :null => false
      t.column :credential, :string, :null => false      
      t.column :request_url, :string
      t.column :format, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :harvest_expenses
  end
end