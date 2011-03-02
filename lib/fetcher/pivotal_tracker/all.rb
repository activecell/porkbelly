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
        
        puts "====== Credential = #{self.credential} ===="
      end
      
      def fetch_all
        begin
          if single_fetch?
            puts "===> Starting Pivotal Tracker single fetching..."
            logger.info "===> Starting Pivotal Tracker single fetching..."
            fetch_single(self.credential)
          else
            puts "===> Starting Pivotal Tracker multiple fetching..."
            logger.info "===> Starting Pivotal Tracker multiple fetching..."
            self.credential.each do |c|
              begin
                fetch_single(c)
              rescue Exception => exc
                logger.error "Error when fetching with credential: #{c}"
                puts exc
              end
            end
          end
        rescue Exception => exc
          logger.error exc
          logger.error exc.backtrace
          #notify_exception(SITE, exc)
          raise exc
        end
      end
      
      private
      def fetch_single(credential)
        return nil if !credential.is_a?(Hash) || credential.blank?
        token = ''
        credential.to_options!
        
        if !credential[:token].blank?
          token = credential[:token]
        elsif !credential[:username].blank? && !credential[:password].blank?
          token = get_token(credential[:username], credential[:password])
        end
        
        if !token.blank?
          project_ids = fetch_projects(token)
          project_ids.each do |project_id|
            logger.info "===> Fetching data of project: #{project_id}..."
            
            fetch_activities(token, {:project_id => project_id})
            fetch_memberships(token, {:project_id => project_id})
            fetch_iterations(token, {:project_id => project_id})
            
            story_ids = fetch_stories(token, {:project_id => project_id})
            story_ids.each do |story_id|
              fetch_notes(token, {:project_id => project_id, :story_id => story_id})
              
              begin
                # Pivotal Tracker might not support task anymore.
                fetch_tasks(token, {:project_id => project_id, :story_id => story_id})
              rescue Exception => exc
                # The Pivotal Tracker service always raises "404 Resource not found" exception
                # when we retrieve story's tasks.
                # This code is for inspecting only.
                puts "ERROR: cannot retrieve task for story: #{story_id}.\n #{exc}"
              end
            end
            
            logger.info "===> Finish fetching data of project: #{project_id}..."
          end
        end
        return nil
      end
    end
  end
end
