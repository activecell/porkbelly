class CreateParsedZendeskTicketFields < ActiveRecord::Migration
  def self.up
    create_table :zendesk_ticket_fields do |t|
      t.column	:account_id	, :string
      t.column	:srv_created_at	, :string
      t.column	:description	, :string
      t.column	:target_id	, :string	,:null => false
      t.column	:is_active	, :string
      t.column	:is_collapsed_for_agents	, :string
      t.column	:is_editable_in_portal	, :string
      t.column	:is_required	, :string
      t.column	:is_required_in_portal	, :string
      t.column	:is_visible_in_portal	, :string
      t.column	:position	, :string
      t.column	:regexp_for_validation	, :string
      t.column	:sub_type_id	, :string
      t.column	:tag	, :string
      t.column	:title	, :string
      t.column	:title_in_portal	, :string
      t.column	:type_ele	, :string
      t.column	:srv_updated_at	, :string
     t.timestamps
    end
  end

  def self.down
    drop_table :zendesk_ticket_fields
  end
end

