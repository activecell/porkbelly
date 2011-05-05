module BusinessDomain
  module Zendesk
    class Ticket < Base

#      TODO: remove comments to make association
#      has_many :ticket_comments
#      has_many :ticket_field_entries
#      has_many :view_tickets
#      has_many :comments, :through => :ticket_comments
#      has_many :ticket_field_entries, :through => :ticket_field_entries
#      has_many :views, :through => :view_tickets

      def self.table_name
        "zendesk_tickets"
      end

######################
#      override method
######################
      def self.src_data
        return ::Zendesk::Ticket
      end

      def self.filter_params
        params = {}
        params.update :parent => '/ticket'
        params.update :mapper => [[:assigned_at,'assigned-at'],
                                  [:assignee_id,'assignee-id'],
                                  [:base_score,'base-score'],
                                  [:srv_created_at,'created-at'],
                                  [:current_collaborators,'current-collaborators'],
                                  [:current_tags,'current-tags'],
                                  [:description,'description'],
                                  [:due_date,'due-date'],
                                  [:entry_id,'entry-id'],
                                  [:external_id,'external-id'],
                                  [:group_id,'group-id'],
                                  [:initially_assigned_at,'initially-assigned-at'],
                                  [:latest_recipients,'latest-recipients'],
                                  [:nice_id,'nice-id'],
                                  [:organization_id,'organization-id'],
                                  [:original_recipient_address,'original-recipient-address'],
                                  [:priority_id,'priority-id'],
                                  [:recipient,'recipient'],
                                  [:requester_id,'requester-id'],
                                  [:resolution_time,'resolution-time'],
                                  [:solved_at,'solved-at'],
                                  [:status_id,'status-id'],
                                  [:status_updated_at,'status-updated-at'],
                                  [:subject,'subject'],
                                  [:submitter_id,'submitter-id'],
                                  [:ticket_type_id,'ticket-type-id'],
                                  [:updated_at,'updated-at'],
                                  [:updated_by_type_id,'updated-by-type-id'],
                                  [:via_id,'via-id'],
                                  [:score,'score'],
                                  [:problem_id,'problem-id'],
                                  [:linkings,'linkings'],
                                  [:channel,'channel']]
        params.update :key_field => :nice_id
        params.update :change => [:nice_id,:target_id]
        return params
      end

      def self.update_data(arr_obj)
        transaction do
          arr_obj.each do |arr_ele|
            arr_ele.each do |o|
              object = self.find_or_initialize_by_nice_id(o[:nice_id])
              object.update_attributes(o)
            end unless arr_ele.nil?
          end
        end
      end
    end
  end
end

