module BusinessDomain
  module Zendesk
    class View < Base

      has_many :view_tickets
      has_many :tickets, :through => :view_tickets


      def self.table_name
        "zendesk_views"
      end

######################
#      override method
######################
      def self.src_data
        return ::Zendesk::View
      end


      def self.filter_params
        params = {}
        params.update :parent => '/view'
        params.update :mapper => [[:target_id,'id'],
                                  [:is_active,'is-active'],
                                  [:owner_id,'owner-id'],
                                  [:owner_type,'owner-type'],
                                  [:per_page,'per-page'],
                                  [:position,'position'],
                                  [:title,'title']]
        params.update :key_field => :target_id
        return params
      end
    end
  end
end

