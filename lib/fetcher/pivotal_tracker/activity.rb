module Fetcher
  module PivotalTracker
    module Activity
      include Fetcher::PivotalTracker::Base
      
      # Fetch project activities
      # == Parameters
      #   + token: API token
      #   + params: require params[:project_id]
      def fetch_activities(token, params)
        params.to_options!
        
        # Setup params.
        setup_params_logic = lambda do |last_request, params|
          if !last_request.blank?
            params[:occurred_since_date] = last_request
          end
        end
        
        # Parse the response.
        response_parse_logic = lambda do |response|        
          content_keys = {}
          doc = Nokogiri::XML(response.body)
          
          doc.xpath("/activities/activity").each do |act|
            id = act.search('id').first.inner_html
            content_keys[id] = act.to_s
          end
          content_keys
        end
        
        url = format_project_url(get_api_url('activities'), params[:project_id])
        fetch(::PivotalTracker::Activity, token, url, 
          response_parse_logic, setup_params_logic, true)
      end
    end
  end
end  
