require 'logger'
require "active_support/core_ext"
require 'rest-client'
require 'nokogiri'

module Fetcher
  module GA
    module Base
      include Fetcher::Base

      attr_accessor :auth_key

      GA_CONFIG = APIS_CONFIG['ga']
      SITE = "GA"
        @@logger = BaseLogger.new(File.join(File.dirname(__FILE__), "..", "..", "..", "log", "ga.log"))
      def logger
        @@logger
      end

      def login
        request_login_url =  GA_CONFIG["auth_url"].gsub(/\[EMAIL\]/, credential[:username]).gsub(/\[PASSWORD\]/, credential[:password])
        puts request_login_url
        response_login = create_login_request(credential, request_login_url).get.to_s
        @auth_key = response_login.split("Auth=").last
      end

      def logout
        @auth_key = nil
        @account_id = nil
      end

      def create_login_request(credential, request_url, params = {})
        RestClient::Resource.new(request_url, 
                                 :user => credential[:username],
                                 :password => credential[:password],
                                 :content_type => "application/x-www-form-urlencoded",
                                 :accept => :xml,
                                 :params => {})
      end

      def create_request(request_url)
        RestClient.get request_url, :authorization => "GoogleLogin auth=#{auth_key}", "GData-Version" => "2"
      end

      def extract_credential(credential)
        {:username => credential[:username]}.inspect
      end
    end
  end
end
