module Fetcher
  module PivotalTracker
    module Iteration
      include Fetcher::PivotalTracker::Base
      
      # Fetch project memberships
      # == Parameters
      #   + token: API token
      #   + params: require params[:project_id]
      def fetch_iterations(token, params)
        params.to_options!
        
        # Setup params.
        setup_params_logic = lambda do |last_request, params|
          # Do nothing.
        end
        
        # Parse the response.
        response_parse_logic = lambda do |response|        
          content_keys = {}
          doc = Nokogiri::XML(response.body)
          
          doc.xpath("/iterations/iteration").each do |act|
            id = act.search('id').first.inner_html
            content_keys[id] = act.to_s
          end
          content_keys
        end
        
        url = format_project_url(get_api_url('iterations'), params[:project_id])
        fetch(::PivotalTracker::Iteration, token, url, 
          response_parse_logic, setup_params_logic, false)
      end
    end
  end
end  
