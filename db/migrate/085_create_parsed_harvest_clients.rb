class CreateParsedHarvestClients < ActiveRecord::Migration
  def self.up
    create_table :harvest_clients do |t|
      t.column :name, :string
      t.column :srv_created_at, :string
      t.column :details, :string
      t.column :srv_updated_at, :string
      t.column :highrise_id, :string
      t.column :target_id, :string,:null => false
      t.column :cache_version, :string
      t.column :default_invoice_timeframe, :string
      t.column :currency, :string
      t.column :active, :string
      t.column :currency_symbol, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :harvest_clients
  end
end

