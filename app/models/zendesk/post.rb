module BusinessDomain
  module Zendesk
    class Post < Base

      belongs_to :entry
      belongs_to :user
      belongs_to :forum

      def self.table_name
        "zendesk_posts"
      end

######################
#      override method
######################
      def self.src_data
        return ::Zendesk::Post
      end

      def self.filter_params
        params = {}
        params.update :parent => '/post'
        params.update :mapper => [[:account_id,'account-id'],
                                  [:body,'body'],
                                  [:srv_created_at,'created-at'],
                                  [:entry_id,'entry-id'],
                                  [:forum_id,'forum-id'],
                                  [:target_id,'id'],
                                  [:is_informative,'is-informative'],
                                  [:srv_updated_at,'updated-at'],
                                  [:user_id,'user-id']]
        params.update :key_field => :target_id
        return params
      end
    end
  end
end

