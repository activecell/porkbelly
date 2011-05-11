class CreateParsedZendeskTicketFieldEntries < ActiveRecord::Migration
  def self.up
    create_table :zendesk_ticket_field_entries do |t|
      t.column	:ticket_field_id	, :string	,:null => false
      t.column	:ticket_id	, :string	,:null => false
      t.column	:value	, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :zendesk_ticket_field_entries
  end
end

