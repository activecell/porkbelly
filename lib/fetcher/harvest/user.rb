require 'nokogiri'

module Fetcher
  module Harvest
    module User
      include Fetcher::Harvest::Base

      def fetch_people(credential)
        response_parse_logic = lambda {|response|
          content_keys = {}
          doc = Nokogiri::XML(response)
          doc.xpath("/users/user").each do |node|
            content_keys["#{node.xpath("//id").first.text}"] = node.to_s
          end
          return content_keys
        }
        fetch(::Harvest::User, credential, HARVEST_CONFIG["apis"]["people"], response_parse_logic)
      end
    end
  end
end
