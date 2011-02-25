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
        options = {
          :user => credential[:username], 
          :password => credential[:password],
          :content_type => :xml, 
          :accept => :xml
        }
        # convert params hash to request param string
        request_url = request_url + "?" + hash_to_param_string(params) unless params.empty?
        logger.info "Create request for url #{request_url}"
        RestClient::Resource.new(request_url, options)
      end

    end
  end
end
