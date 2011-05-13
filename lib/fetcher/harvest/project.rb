require 'nokogiri'

module Fetcher
  module Harvest
    module Project
      include Fetcher::Harvest::Base

      def fetch_projects(credential)
        response_parse_logic = lambda {|response|
          content_keys = {}
          doc = Nokogiri::XML(response)
          doc.xpath("/projects/project").each do |node|
            content_keys["#{node.xpath("id").text}"] = node.to_s
          end
          return content_keys
        }
        fetch(::Harvest::Project, credential, HARVEST_CONFIG["apis"]["projects"], response_parse_logic)
      end
    end
  end
end
