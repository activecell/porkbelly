class CreateParsedHarvestExpenses < ActiveRecord::Migration
  def self.up
    create_table :harvest_expenses do |t|
      t.column :srv_created_at , :string 
      t.column :is_billed , :string 
      t.column :notes , :string 
      t.column :project_id , :string 
      t.column :srv_updated_at , :string 
      t.column :spent_at , :string 
      t.column :units , :string 
      t.column :target_id , :string ,:null => false
      t.column :is_closed , :string 
      t.column :user_id , :string 
      t.column :expense_category_id , :string 
      t.column :total_cost , :string 
      t.column :has_receipt , :string 
      t.column :receipt_url , :string 
      t.timestamps
    end
  end

  def self.down
    drop_table :harvest_expenses
  end
end

