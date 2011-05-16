class CreateParsedHarvestPayments < ActiveRecord::Migration
  def self.up
    create_table :harvest_payments do |t|
      t.column	:srv_created_at	, :string	
      t.column	:pay_pal_transaction_id	, :string	
      t.column	:notes	, :string	
      t.column	:recorded_by_email	, :string	
      t.column	:srv_updated_at	, :string	
      t.column	:amount	, :string	
      t.column	:invoice_id	, :string	
      t.column	:payment_gateway_id	, :string	
      t.column	:authorization	, :string	
      t.column	:target_id	, :string	,:null => false
      t.column	:recorded_by	, :string	
      t.column	:paid_at	, :string	
      t.timestamps
    end
  end

  def self.down
    drop_table :harvest_payments
  end
end

