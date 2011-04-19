class CreateParsedPtPersons < ActiveRecord::Migration
  def self.up
    create_table :pt_persons do |t|
      t.column :email, :string, :null => false
      t.column :name, :string
      t.column :initials, :string
      t.timestamps
    end
  end
  def self.down
    drop_table :pt_persons
  end
end

