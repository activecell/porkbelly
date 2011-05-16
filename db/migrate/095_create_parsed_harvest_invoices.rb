class CreateParsedHarvestInvoices < ActiveRecord::Migration
  def self.up
    create_table :harvest_invoices do |t|
      t.column	:number	, :string	
      t.column	:period_end	, :string	
      t.column	:tax	, :string	
      t.column	:srv_created_at	, :string	
      t.column	:discount	, :string	
      t.column	:due_at_human_format	, :string	
      t.column	:notes	, :string	
      t.column	:srv_updated_at	, :string	
      t.column	:amount	, :string	
      t.column	:client_key	, :string	
      t.column	:discount_amount	, :string	
      t.column	:period_start	, :string	
      t.column	:recurring_invoice_id	, :string	
      t.column	:due_amount	, :string	
      t.column	:target_id	, :string	,:null => false
      t.column	:subject	, :string	
      t.column	:tax_amount	, :string	
      t.column	:client_id	, :string	
      t.column	:purchase_order	, :string	
      t.column	:tax2_amount	, :string	
      t.column	:currency	, :string	
      t.column	:retainer_id	, :string	
      t.column	:estimate_id	, :string	
      t.column	:issued_at	, :string	
      t.column	:tax2	, :string	
      t.column	:due_at	, :string	
      t.column	:state	, :string	
      t.timestamps
    end
  end

  def self.down
    drop_table :harvest_invoices
  end
end

