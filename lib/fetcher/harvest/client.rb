require 'nokogiri'

module Fetcher
  module Harvest
    module Client
      include Fetcher::Harvest::Base

      def fetch_clients(credential)
        response_parse_logic = lambda do |response|
          content_keys = {}
          doc = Nokogiri::XML(response)
          doc.xpath("/clients/client").each do |node|
            content_keys["#{node.xpath("//id").first.text}"] = node.to_s
          end
          content_keys
        end
        fetch(::Harvest::Client, credential, HARVEST_CONFIG["apis"]["clients"], response_parse_logic)
      end
    end
  end
end
