class CreateParsedPtIterations < ActiveRecord::Migration
  def self.up
    create_table :pt_iterations do |t|
      t.column :target_id	 , :string	 , :null => false
      t.column :number	 , :string
      t.column :start	 , :string
      t.column :finish	 , :string
      t.column :team_strength	 , :string
      t.timestamps
    end
  end

  def self.down
    drop_table :pt_iterations
  end
end

