require 'nokogiri'

module Fetcher
  module Harvest
    module UserAssignment
      include Fetcher::Harvest::Base

      def fetch_user_assignments(credential, project_ids)
        response_parse_logic = lambda do |response|
          content_keys = {}
          doc = Nokogiri::XML(response)
          doc.xpath("/user-assignments/user-assignment").each do |node|
            content_keys["#{node.xpath("id").first.text}"] = node.to_s
          end
          content_keys
        end

        project_ids.each do |pid|
          fetch(::Harvest::UserAssignment, credential, HARVEST_CONFIG["apis"]["user_assignments"].gsub("[PROJECT_ID]", pid), response_parse_logic, true, {:project_id => pid})
        end
      end
    end
  end
end
