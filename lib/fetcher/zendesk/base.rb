require "logger"
require "yaml"
require "rest-client"
require "rexml/document"
require "active_support/core_ext"

module Fetcher
  module Zendesk
    module Base
      include Fetcher::Base
      include REXML

      ZENDESK_CONFIG = APIS_CONFIG['zendesk']
      SITE = "ZENDESK"

      @@logger = BaseLogger.new(File.join(File.dirname(__FILE__), "..", "..", "..", "log", "zendesk.log"))
      def logger
        @@logger
      end

      def create_request(credential, request_url, params = {})
        RestClient::Resource.new(request_url, 
                                 :user => credential[:username],
                                 :password => credential[:password],
                                 :content_type => :xml,
                                 :accept => :xml,
                                 :params => {})
      end

      #get content key (target id) from response
      def extract_content_keys(response)
        doc = Document.new response
        extracted_keys = Array.new
        for i in 1..doc.root.elements.size do
          key_value_pair = {doc.root.elements[i].elements["id"].text.to_i => doc.root.elements[i].to_s}
          extracted_keys[i-1] = key_value_pair
        end
        extracted_keys
      end

      #checking for existing record
      def check_existence_record(entity, data)
        if entity.where(:content => data).exists?
          return true
        else return false
        end
      end

    end
  end
end
