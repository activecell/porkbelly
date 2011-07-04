class CreateParsedPtMemberships < ActiveRecord::Migration
  def self.up
    create_table :pt_memberships do |t|
      t.column :target_id	 , :string	 , :null => false
      t.column :person_id	 , :string	 , :null => false
      t.column :role	 , :text
      t.column :project_id	 , :string	 , :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :pt_memberships
  end
end

