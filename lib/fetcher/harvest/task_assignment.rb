require "rexml/document"
include REXML

module Fetcher
  module Harvest
    module TaskAssignment
      include Fetcher::Harvest::Base

      def fetch_task_assignments(credential, project_ids)
        response_parse_logic = lambda do |response|
          content_keys = {}
          doc = Document.new(response)
          doc.elements.each("task-assignments/task-assignment") do |ec| 
            content_keys["#{ec.elements["id"].text}"] = ec.to_s
          end
          content_keys
        end

        project_ids.each do |pid|
          fetch(::Harvest::TaskAssignment, credential, HARVEST_CONFIG["apis"]["task_assignments"].gsub("[PROJECT_ID]", pid), response_parse_logic, true, {:project_id => pid})
        end
      end
    end
  end
end
