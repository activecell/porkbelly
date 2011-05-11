module BusinessDomain
  module Zendesk
    class Macro < Base

#      has_many :entries
#      has_many :posts

      def self.table_name
        "zendesk_macros"
      end

######################
#      override method
######################
      def self.src_data
        return ::Zendesk::Macro
      end

      def self.filter_params
        params = {}
        params.update :parent => '/macro'
        params.update :mapper => [[:target_id	,'id'],
                                  [:title	,'title'],
                                  [:availability_type	,'availability-type']]
        params.update :key_field => :target_id
        return params
      end
    end
  end
end

