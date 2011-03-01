module Fetcher
  module PivotalTracker
    module Project
      include Fetcher::PivotalTracker::Base
      
      def fetch_projects(token)
        response_parse_logic = lambda do |response|        
          content_keys = {}
          doc = Nokogiri::XML(response.body)
          
          doc.xpath("/projects/project").each do |project|
            id = project.search('id').first.inner_html #Or: (project/'id').first.inner_html
            content_keys[id] = project.to_s
          end
          
          content_keys
        end
        
        setup_params_logic = lambda do |last_request, params|
          # Do nothing.
        end
        
        fetch(::PivotalTracker::Project, token, get_api_url('projects'), 
          response_parse_logic, setup_params_logic, false)
      end
    end
  end
end
