require "rexml/document"
include REXML

module Fetcher
  module Harvest
    module Contact
      include Fetcher::Harvest::Base

      def fetch_contacts(credential)
        response_parse_logic = lambda {|response|
          content_keys = {}
          doc = Document.new(response)
          doc.elements.each("contacts/contact") do |contact| 
            content_keys["#{contact.elements["id"].text}"] = contact.to_s
          end
          return content_keys
        }
        fetch(::Harvest::Contact, credential, HARVEST_CONFIG["apis"]["contacts"], response_parse_logic)
      end
    end
  end
end
