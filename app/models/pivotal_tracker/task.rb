module BusinessDomain
  module PivotalTracker
    class Task < Base

      belongs_to :story

      def self.table_name
          "pt_tasks"
      end

######################
#      override method
######################
      def self.src_data
        return ::PivotalTracker::Task
      end

      def self.filter_params
        params = {}
        params.update :parent => '/task'
        params.update :mapper => [[:target_id,'id'],
                                  [:description,'description'],
                                  [:position,'position'],
                                  [:complete,'complete'],
                                  [:srv_created_at,'created_at']]
        params.update :key_field => :target_id
        params.update :change => [:story_id,:story_id]
        return params
      end
    end
  end
end

