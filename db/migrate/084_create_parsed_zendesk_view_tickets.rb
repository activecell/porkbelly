class CreateParsedZendeskViewTickets < ActiveRecord::Migration
  def self.up
    create_table :zendesk_view_tickets do |t|
      t.column	:view_id	, :string	,:null => false
      t.column	:ticket_id	, :string	,:null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :zendesk_view_tickets
  end
end

