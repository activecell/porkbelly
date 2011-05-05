class CreateParsedZendeskTickets < ActiveRecord::Migration
  def self.up
    create_table :zendesk_tickets do |t|
      t.column	:assigned_at	, :string
      t.column	:assignee_id	, :string
      t.column	:base_score	, :string
      t.column	:srv_created_at	, :string
      t.column	:current_collaborators	, :string
      t.column	:current_tags	, :string
      t.column	:description	, :text
      t.column	:due_date	, :string
      t.column	:entry_id	, :string
      t.column	:external_id	, :string
      t.column	:group_id	, :string
      t.column	:initially_assigned_at	, :string
      t.column	:latest_recipients	, :string
      t.column	:nice_id	, :string	,:null => false
      t.column	:organization_id	, :string
      t.column	:original_recipient_address	, :string
      t.column	:priority_id	, :string
      t.column	:recipient	, :string
      t.column	:requester_id	, :string
      t.column	:resolution_time	, :string
      t.column	:solved_at	, :string
      t.column	:status_id	, :string
      t.column	:status_updated_at	, :string
      t.column	:subject	, :string
      t.column	:submitter_id	, :string
      t.column	:ticket_type_id	, :string
      t.column	:updated_at	, :string
      t.column	:updated_by_type_id	, :string
      t.column	:via_id	, :string
      t.column	:score	, :string
      t.column	:problem_id	, :string
      t.column	:linkings	, :string
      t.column	:channel	, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :zendesk_tickets
  end
end

