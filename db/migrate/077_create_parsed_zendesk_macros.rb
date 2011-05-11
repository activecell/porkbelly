class CreateParsedZendeskMacros < ActiveRecord::Migration
  def self.up
    create_table :zendesk_macros do |t|
      t.column	:target_id	, :string	,:null => false
      t.column	:title	, :string
      t.column	:availability_type	, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :zendesk_macros
  end
end

