class CreateParsedHarvestContacts < ActiveRecord::Migration
  def self.up
    create_table :harvest_contacts do |t|
      t.column :target_id , :string ,:null => false
      t.column :client_id , :string 
      t.column :email , :string 
      t.column :first_name , :string 
      t.column :last_name , :string 
      t.column :phone_office , :string 
      t.column :phone_mobile , :string 
      t.column :fax , :string 
      t.column :srv_updated_at , :string 
      t.column :srv_created_at , :string 
      t.timestamps
    end
  end

  def self.down
    drop_table :harvest_contacts
  end
end

