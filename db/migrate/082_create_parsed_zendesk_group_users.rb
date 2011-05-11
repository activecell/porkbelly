class CreateParsedZendeskGroupUsers < ActiveRecord::Migration
  def self.up
    create_table :zendesk_group_users do |t|
      t.column	:group_id	, :string	,:null => false
      t.column	:user_id	, :string	,:null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :zendesk_group_users
  end
end

