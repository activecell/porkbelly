require "rexml/document"
include REXML

module Fetcher
  module Harvest
    module Expense
      include Fetcher::Harvest::Base

      def fetch_expenses(credential)
        response_parse_logic = lambda {|response|
          content_keys = {}
          doc = Document.new(response)
          doc.elements.each("expenses/expense") do |contact| 
            content_keys["#{contact.elements["id"].text}"] = contact.to_s
          end
          return content_keys
        }
        fetch("Expense", ::Harvest::Expense, credential, HARVEST_CONFIG["apis"]["expenses"], response_parse_logic)
      end
    end
  end
end
