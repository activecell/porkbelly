module BusinessDomain
  module PivotalTracker
    class Activity < Base

      has_one :history_track
      has_one :story, :through => :history_track

      def self.table_name
        "pt_activities"
      end

######################
#      override method
######################
      def self.src_data
        return ::PivotalTracker::Activity
      end

      def self.filter_params
        params = {}
        params.update :parent => '/activity'
        params.update :mapper => [[:target_id,'id'],
                            [:version,'version'],
                            [:event_type,'event_type'],
                            [:occurred_at,'occurred_at'],
                            [:author,'author'],
                            [:project_id, 'project_id'],
                            [:description,'description']]
        params.update :key_field => :target_id
        return params
      end
    end
  end
end

