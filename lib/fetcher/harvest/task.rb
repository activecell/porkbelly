require 'nokogiri'

module Fetcher
  module Harvest
    module Task
      include Fetcher::Harvest::Base

      def fetch_tasks(credential)
        response_parse_logic = lambda do |response|
          content_keys = {}
          doc = Nokogiri::XML(response)
          doc.xpath("/tasks/task").each do |node|
            content_keys["#{node.xpath("//id").first.text}"] = node.to_s
          end
          content_keys
        end
        fetch(::Harvest::Task, credential, HARVEST_CONFIG["apis"]["tasks"], response_parse_logic)
      end
    end
  end
end
