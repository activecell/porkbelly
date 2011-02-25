require "rexml/document"
include REXML

module Fetcher
  module Harvest
    module Client
      include Fetcher::Harvest::Base

      def fetch_clients(credential)
        response_parse_logic = Proc.new do |response|
          content_keys = {}
          doc = Document.new(response)
          doc.elements.each("clients/client") do |client| 
            content_keys["#{client.elements["id"].text}"] = client.to_s
          end
          content_keys
        end
        fetch(::Harvest::Client, credential, HARVEST_CONFIG["apis"]["clients"], response_parse_logic)
      end
    end
  end
end
