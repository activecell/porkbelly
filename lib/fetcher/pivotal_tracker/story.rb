module Fetcher
  module PivotalTracker
    module Story
      include Fetcher::PivotalTracker::Base
      
      # Fetch project stories.
      # == Parameters
      #   + token: API token
      #   + params: require params[:project_id]
      def fetch_stories(token, params)
        params.to_options!
        
        # Setup params.
        setup_params_logic = lambda do |last_request, params|
          if !last_request.blank?
            params[:modified_since] = last_request
          end
        end
        
        # Parse the response.
        response_parse_logic = lambda do |response|        
          content_keys = {}
          doc = Nokogiri::XML(response.body)
          
          doc.xpath("/stories/story").each do |story|
            id = story.search('id').first.inner_html
            content_keys[id] = story.to_s
          end
          content_keys
        end
        
        url = format_project_url(get_api_url('stories'), params[:project_id])
        fetch(::PivotalTracker::Story, token, url, 
          response_parse_logic, setup_params_logic, true)
      end
    end
  end
end  
