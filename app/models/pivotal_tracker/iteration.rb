module BusinessDomain
  module PivotalTracker
    class Iteration < Base

      belongs_to :project
      has_many :iteration_stories
      has_many :stories, :through => :iteration_stories

      def self.table_name
          "pt_iterations"
      end

######################
#      override method
######################
      def self.src_data
        return ::PivotalTracker::Iteration
      end

      def self.filter_params
        params = {}
        params.update :parent => '/iteration'
        params.update :mapper => [[:target_id,'id'],
                                  [:number,'number'],
                                  [:start,'start'],
                                  [:finish,'finish'],
                                  [:team_strength,'team_strength']]
        params.update :key_field => :target_id
        params.update :change => [:project_id,:project_id]
        return params
      end
    end
  end
end

