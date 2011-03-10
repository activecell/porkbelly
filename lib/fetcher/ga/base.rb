require 'logger'
require 'garb'
require "active_support/core_ext"
require 'rest-client'
require 'nokogiri'

module Fetcher
  module GA
    module Base
      include Fetcher::Base

      GA_CONFIG = APIS_CONFIG['ga']
      SITE = "GA"
        @@logger = BaseLogger.new(File.join(File.dirname(__FILE__), "..", "..", "..", "log", "ga.log"))
      def logger
        @@logger
      end

      def create_login_request(credential, request_url, params = {})
        RestClient::Resource.new(request_url, 
                                 :user => credential[:username],
                                 :password => credential[:password],
                                 :content_type => "application/x-www-form-urlencoded",
                                 :accept => :xml,
                                 :params => {})
      end

      def create_request(auth_key, request_url, params = {})
        @@auth_key = auth_key
        RestClient.get request_url, :authorization => "GoogleLogin auth=#{auth_key}"
      end

    end
  end
end
