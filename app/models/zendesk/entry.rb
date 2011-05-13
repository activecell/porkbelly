module BusinessDomain
  module Zendesk
    class Entry < Base

      belongs_to :forum
      has_many :posts

      def self.table_name
        "zendesk_entries"
      end

######################
#      override method
######################
      def self.src_data
        return ::Zendesk::Entry
      end

      def self.filter_params
        params = {}
        params.update :parent => '/entry'
        params.update :mapper => [[:body,'body'],
                                  [:srv_created_at,'created-at'],
                                  [:current_tags,'current-tags'],
                                  [:flag_type_id,'flag-type-id'],
                                  [:forum_id,'forum-id'],
                                  [:hits,'hits'],
                                  [:target_id,'id'],
                                  [:is_highlighted,'is-highlighted'],
                                  [:is_locked,'is-locked'],
                                  [:is_pinned,'is-pinned'],
                                  [:is_public,'is-public'],
                                  [:organization_id,'organization-id'],
                                  [:position,'position'],
                                  [:posts_count,'posts-count'],
                                  [:submitter_id,'submitter-id'],
                                  [:title,'title'],
                                  [:srv_updated_at,'updated-at'],
                                  [:votes_count,'votes-count']]
        params.update :key_field => :target_id
        return params
      end
    end
  end
end

