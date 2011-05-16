class CreateParsedHarvestInvoiceCategories < ActiveRecord::Migration
  def self.up
    create_table :harvest_invoice_categories do |t|
      t.column	:name	, :string	
      t.column	:srv_created_at	, :string	
      t.column	:srv_updated_at	, :string	
      t.column	:use_as_expense	, :string	
      t.column	:use_as_service	, :string	
      t.column	:target_id	, :string	,:null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :harvest_invoice_categories
  end
end

