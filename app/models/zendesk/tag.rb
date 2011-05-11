module BusinessDomain
  module Zendesk
    class Tag < Base

#      belongs_to :entry
#      belongs_to :user
#      belongs_to :forum

      def self.table_name
        "zendesk_tags"
      end

######################
#      override method
######################
      def self.src_data
        return ::Zendesk::Tag
      end

      def self.filter_params
        params = {}
        params.update :parent => '/tag-score'
        params.update :mapper => [[:account_id	,'account-id'],
                                  [:target_id	,'id'],
                                  [:score	,'score'],
                                  [:tag_id	,'tag-id'],
                                  [:tag_name	,'tag-name']]
        params.update :key_field => :target_id
        return params
      end
    end
  end
end

