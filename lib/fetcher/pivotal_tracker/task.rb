module Fetcher
  module PivotalTracker
    module Task
      include Fetcher::PivotalTracker::Base
      
      # Fetch project stories.
      # == Parameters
      #   + token: API token
      #   + params: require params[:project_id] and params[:story_id]
      def fetch_tasks(token, params)
        params.to_options!
        
        # Setup params.
        setup_params_logic = lambda do |last_request, params|
          # Do nothing.
        end
        
        # Parse the response.
        response_parse_logic = lambda do |response|        
          content_keys = {}
          doc = Nokogiri::XML(response.body)
          
          doc.xpath("/tasks/task").each do |task|
            id = task.search('id').first.inner_html
            content_keys[id] = task.to_s
          end
          content_keys
        end
        
        url = get_api_url('tasks')
        url = format_project_url(url, params[:project_id])
        url = format_story_url(url, params[:story_id])
        fetch(::PivotalTracker::Task, token, url, 
          response_parse_logic, setup_params_logic, false)
      end
    end
  end
end  
