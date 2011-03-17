class ChangeZendeskRequestUrlToText < ActiveRecord::Migration
  def self.up    
    [ :zendesk_entries,
      :zendesk_forums,
      :zendesk_groups,
      :zendesk_macros,
      :zendesk_organizations,
      :zendesk_tags,
      :zendesk_ticket_fields,
      :zendesk_users].each do |table_name|
        change_table table_name do |t|
          t.change :request_url, :text
        end
    end
  end
end
