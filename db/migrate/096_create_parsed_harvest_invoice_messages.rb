class CreateParsedHarvestInvoiceMessages < ActiveRecord::Migration
  def self.up
    create_table :harvest_invoice_messages do |t|
      t.column	:sent_by_email	, :string	
      t.column	:srv_created_at	, :string	
      t.column	:include_pay_pal_link	, :string	
      t.column	:thank_you	, :string	
      t.column	:body	, :text	
      t.column	:send_me_a_copy	, :string	
      t.column	:srv_updated_at	, :string	
      t.column	:invoice_id	, :string	
      t.column	:target_id	, :string	,:null => false
      t.column	:subject	, :string	
      t.column	:sent_by	, :string	
      t.column	:full_recipient_list	, :string	
      t.timestamps
    end
  end

  def self.down
    drop_table :harvest_invoice_messages
  end
end

