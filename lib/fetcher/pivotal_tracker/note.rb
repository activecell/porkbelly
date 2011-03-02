module Fetcher
  module PivotalTracker
    module Note
      include Fetcher::PivotalTracker::Base
      
      # Fetch project stories.
      # == Parameters
      #   + token: API token
      #   + params: require params[:project_id] and params[:story_id]
      def fetch_notes(token, params)
        params.to_options!
        
        # Setup params.
        setup_params_logic = lambda do |last_request, params|
          # Do nothing.
        end
        
        # Parse the response.
        response_parse_logic = lambda do |response|        
          content_keys = {}
          doc = Nokogiri::XML(response.body)
          
          doc.xpath("/notes/note").each do |note|
            id = note.search('id').first.inner_html
            content_keys[id] = note.to_s
          end
          content_keys
        end
        
        url = get_api_url('notes')
        url = format_project_url(url, params[:project_id])
        url = format_story_url(url, params[:story_id])
        fetch(::PivotalTracker::Note, token, url, 
          response_parse_logic, setup_params_logic, false)
      end
    end
  end
end  
