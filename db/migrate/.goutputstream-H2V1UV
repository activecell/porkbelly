class CreateParsedZendeskTicketComments < ActiveRecord::Migration
  def self.up
    create_table :zendesk_ticket_comments do |t|
      t.column	:ticket_id	, :string	,:null => false
      t.column	:comment_id	, :string	,:null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :zendesk_ticket_comments
  end
end

