module BusinessDomain
  module Zendesk
    class Group < Base

      has_many :group_users

      def self.table_name
        "zendesk_groups"
      end

######################
#      override method
######################
      def self.src_data
        return ::Zendesk::Group
      end

      def self.filter_params
        params = {}
        params.update :parent => '/group'
        params.update :mapper => [[:srv_created_at,'created-at'],
                                  [:target_id,'id'],
                                  [:is_active,'is-active'],
                                  [:name,'name'],
                                  [:srv_updated_at,'updated-at']]
        params.update :key_field => :target_id
        return params
      end
    end
  end
end

