module Fetcher
  module PivotalTracker
    module Membership
      include Fetcher::PivotalTracker::Base
      
      # Fetch project memberships
      # == Parameters
      #   + token: API token
      #   + params: require params[:project_id]
      def fetch_memberships(token, params)
        params.to_options!
        
        # Setup params.
        setup_params_logic = lambda do |last_request, params|
          # Do nothing.
        end
        
        # Parse the response.
        response_parse_logic = lambda do |response|        
          content_keys = {}
          doc = Nokogiri::XML(response.body)
          
          doc.xpath("/memberships/membership").each do |mem|
            id = mem.search('id').first.inner_html
            content_keys[id] = mem.to_s
          end
          content_keys
        end
        
        url = format_project_url(get_api_url('memberships'), params[:project_id])
        fetch(::PivotalTracker::Membership, token, url, 
          response_parse_logic, setup_params_logic, false)
      end
    end
  end
end  
