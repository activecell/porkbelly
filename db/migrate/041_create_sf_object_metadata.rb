class CreateSfObjectMetadata < ActiveRecord::Migration
  def self.up
    create_table :sf_object_metadata do |t|         
      t.column :name, :string, :null => false      
      t.column :url, :string, :null => false 
      t.column :metadata, :text, :null => false
      t.column :credential, :string, :null => false   
      t.column :format, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :sf_object_metadata
  end
end
