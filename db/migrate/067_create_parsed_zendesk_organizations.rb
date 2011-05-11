class CreateParsedZendeskOrganizations < ActiveRecord::Migration
  def self.up
    create_table :zendesk_organizations do |t|
      t.column :srv_created_at	, :string
      t.column :group_id	, :string
      t.column :target_id	, :string	, :null => false
      t.column :is_shared	, :string
      t.column :is_shared_comments	, :string
      t.column :name	, :string	, :null => false
      t.column :notes	, :string
      t.column :srv_updated_at	, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :zendesk_organizations
  end
end

