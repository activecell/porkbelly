module BusinessDomain
  module Zendesk
    class TicketField < Base

#      has_many :entries
#      has_many :posts

      def self.table_name
        "zendesk_ticket_fields"
      end

######################
#      override method
######################
      def self.src_data
        return ::Zendesk::TicketField
      end

      def self.filter_params
        params = {}
        params.update :parent => '/record'
        params.update :mapper => [[:account_id,'account-id'],
                                  [:srv_created_at,'created-at'],
                                  [:title,'title'],
                                  [:target_id,'id'],
                                  [:is_active,'is-active'],
                                  [:is_collapsed_for_agents,'is-collapsed-for-agents'],
                                  [:is_editable_in_portal,'is-editable-in-portal'],
                                  [:is_required,'is-required'],
                                  [:is_required_in_portal,'is-required-in-portal'],
                                  [:is_visible_in_portal,'is-visible-in-portal'],
                                  [:position,'position'],
                                  [:regexp_for_validation,'regexp-for-validation'],
                                  [:sub_type_id,'sub-type-id'],
                                  [:tag,'tag'],
                                  [:title,'title'],
                                  [:title_in_portal,'title-in-portal'],
                                  [:type_ele,'type'],
                                  [:srv_updated_at,'updated-at']]
        params.update :key_field => :target_id
        return params
      end
    end
  end
end

