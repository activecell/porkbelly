class CreateParsedPtNotes < ActiveRecord::Migration
  def self.up
    create_table :pt_notes do |t|
      t.column :target_id	 , :string	 , :null => false
      t.column :text	 , :string
      t.column :author	 , :string
      t.column :noted_at	 , :string
      t.timestamps
    end
  end

  def self.down
    drop_table :pt_notes
  end
end

