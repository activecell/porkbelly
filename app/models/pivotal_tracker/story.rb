module BusinessDomain
  module PivotalTracker
    class Story < Base

      has_many :tasks
      has_many :story_notes
      has_many :notes, :through => :story_notes
      belongs_to :project


      def self.table_name
          "pt_stories"
      end

######################
#      override method
######################
      def self.src_data
        return ::PivotalTracker::Story
      end

      def self.filter_params
        params = {}
        params.update :parent => '/story'
        params.update :mapper => [[:target_id,'id'],
                    [:project_id,'project_id'],
                    [:story_type,'story_type'],
                    [:url,'url'],
                    [:estimate,'estimate'],
                    [:current_state,'current_state'],
                    [:description,'description'],
                    [:name,'name'],
                    [:requested_by,'requested_by'],
                    [:owned_by,'owned_by'],
                    [:srv_created_at,'created_at'],
                    [:srv_updated_at,'updated_at'],
                    [:labels,'labels']]
        params.update :key_field => :target_id
        return params
      end
    end
  end
end

