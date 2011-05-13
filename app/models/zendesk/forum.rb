module BusinessDomain
  module Zendesk
    class Forum < Base

      has_many :entries
      has_many :posts
      belongs_to :organization

      def self.table_name
        "zendesk_forums"
      end

######################
#      override method
######################
      def self.src_data
        return ::Zendesk::Forum
      end

      def self.filter_params
        params = {}
        params.update :parent => '/forum'
        params.update :mapper => [[:category_id,'category-id'],
                                  [:description,'description'],
                                  [:display_type_id,'display-type-id'],
                                  [:entries_count,'entries-count'],
                                  [:target_id,'id'],
                                  [:is_locked,'is-locked'],
                                  [:name,'name'],
                                  [:organization_id,'organization-id'],
                                  [:position,'position'],
                                  [:translation_locale_id,'translation-locale-id'],
                                  [:srv_updated_at,'updated-at'],
                                  [:use_for_suggestions,'use-for-suggestions'],
                                  [:visibility_restriction_id,'visibility-restriction-id'],
                                  [:is_public ,'is-public ']]
        params.update :key_field => :target_id
        return params
      end
    end
  end
end

