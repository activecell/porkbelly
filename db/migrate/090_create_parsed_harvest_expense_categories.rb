class CreateParsedHarvestExpenseCategories < ActiveRecord::Migration
  def self.up
    create_table :harvest_expense_categories do |t|
      t.column	:name	, :string	
      t.column	:srv_created_at	, :string	
      t.column	:srv_updated_at	, :string	
      t.column	:target_id	, :string	,:null => false
      t.column	:unit_price	, :string	
      t.column	:cache_version	, :string	
      t.column	:deactivated	, :string	
      t.column	:unit_name	, :string	
      t.timestamps
    end
  end

  def self.down
    drop_table :harvest_expense_categories
  end
end

