require 'nokogiri'

module Fetcher
  module Harvest
    module Contact
      include Fetcher::Harvest::Base

      def fetch_contacts(credential)
        response_parse_logic = lambda {|response|
          content_keys = {}
          doc = Nokogiri::XML(response)
          doc.xpath("/contacts/contact").each do |node|
            content_keys["#{node.xpath("//id").first.text}"] = node.to_s
          end
          return content_keys
        }
        fetch(::Harvest::Contact, credential, HARVEST_CONFIG["apis"]["contacts"], response_parse_logic)
      end
    end
  end
end
