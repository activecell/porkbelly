module BusinessDomain
  module Zendesk
    class Organization < Base

      has_many :users

      def self.table_name
        "zendesk_organizations"
      end

######################
#      override method
######################
      def self.src_data
        return ::Zendesk::Organization
      end

      def self.filter_params
        params = {}
        params.update :parent => '/organization'
        params.update :mapper => [[:created_at,'created-at'],
                                [:group_id,'group-id'],
                                [:target_id,'id'],
                                [:is_shared,'is-shared'],
                                [:is_shared_comments,'is-shared-comments'],
                                [:name,'name'],
                                [:notes,'notes'],
                                [:updated_at,'updated-at']]
        params.update :key_field => :target_id
        return params
      end
    end
  end
end

