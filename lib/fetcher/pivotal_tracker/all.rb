module Fetcher
  module PivotalTracker
    class All
      include Fetcher::PivotalTracker::Project
      include Fetcher::PivotalTracker::Activity
      include Fetcher::PivotalTracker::Iteration
      include Fetcher::PivotalTracker::Story
      include Fetcher::PivotalTracker::Task
      include Fetcher::PivotalTracker::Note
      include Fetcher::PivotalTracker::Membership
      
      def initialize(credential)
        tmp_credential = normalize_credential!(credential)        
        super(tmp_credential)
      end
      
      def fetch_all
        if single_fetch?
          logger.info "===> Starting Pivotal Tracker single fetching..."
          
        else
          logger.info "===> Starting Pivotal Tracker multiple fetching..."
        end
      end
    end
  end
end
