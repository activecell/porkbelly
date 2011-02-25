require "rexml/document"
include REXML

module Fetcher
  module Harvest
    module Task
      include Fetcher::Harvest::Base

      def fetch_tasks(credential)
        response_parse_logic = Proc.new do |response|
          content_keys = {}
          doc = Document.new(response)
          doc.elements.each("tasks/task") do |client| 
            content_keys["#{client.elements["id"].text}"] = client.to_s
          end
          content_keys
        end
        fetch(::Harvest::Task, credential, HARVEST_CONFIG["apis"]["tasks"], response_parse_logic)
      end
    end
  end
end
