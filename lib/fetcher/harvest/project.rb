module Fetcher
  module Harvest
    module Project
      include Fetcher::Harvest::Base

      def fetch_projects(credential)
        response_parse_logic = lambda {|response|
          content_keys = {}
          doc = Document.new(response)
          doc.elements.each("projects/project") do |project| 
            content_keys["#{project.elements["id"].text}"] = project.to_s
          end
          return content_keys
        }
        fetch(::Harvest::Project, credential, HARVEST_CONFIG["apis"]["projects"], response_parse_logic)
      end
    end
  end
end
