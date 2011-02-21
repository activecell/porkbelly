require File.expand_path("../base", __FILE__)
require File.expand_path("../../models/harvest", __FILE__)
require 'rest-client'

module Fetchers
  module HarvestFetcher
    # Base module for harvest fetchers
    module HarvestFetcherBase
      include Base

      # create logger for Harvest 
      @@logger = BaseLogger.new(File.expand_path("../../../log/harvest.log",__FILE__))
      def logger
        @@logger
      end

      def rest_request(credential, request_url)
        RestClient::Resource.new(request_url, 
                                 :user => credential[:email], 
                                 :password => credential[:password],
                                 :content_type => :xml, 
                                 :accept => :xml)
      end

      def new_client(credential, request_url, format)
        @credential = credential.to_options
        @request_url = request_url
        @format = format
      end
    end

    # Harvest's client fetcher
    class ClientFetcher
      include HarvestFetcherBase

      def initialize(credential, request_url, format)
        new_client(credential, request_url, format)		
        @request = rest_request(credential, request_url)
      end

      def fetch_data			
        data = @request.get.to_s
        logger.info "received data #{data}"

        #if !check_existence_record(zendesk_ticket, data)			
          #Harvest::Client.create(:request_url => @request_url, :content => data, :credential =>	
                                #@credential.to_s, :format => @format)
        #end
      end
    end
  end
end
