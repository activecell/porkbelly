require "logger"
require "yaml"
require "rest-client"

module Fetcher
  module Harvest
    # include this module in all Harvest fetchers
    module Base
      include Fetcher::Base

      HARVEST_CONFIG = APIS_CONFIG['harvest']
      SITE = "HARVEST"

      @@logger = BaseLogger.new(File.join(File.dirname(__FILE__), "..", "..", "..", "log", "harvest.log"))
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

    end
  end
end
