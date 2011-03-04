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

      def extract_account_id(response)
        entry = Nokogiri::XML(response).search("entry")
        account_id = entry.at_xpath("dxp:property").values[1]
        account_id
      end

      def extract_web_property_contents(response)
        entry = Nokogiri::XML(response).search("entry")
        entries = Array.new
        a_ids = Array.new
        wp_ids = Array.new
        contents = Array.new
        i = 0
        for i in (i..entry.xpath("//dxp:property").size - 1) do
          if (i%2 == 0)
            a_id = entry.xpath("//dxp:property")[i].attribute('value').value.to_i
            a_ids << a_id
          else
            wp_id = entry.xpath("//dxp:property")[i].attribute('value').value.to_s
            wp_ids << wp_id
          end
        end
        entry.each do |e|
          entries << e
        end
        contents = [entries, a_ids, wp_ids]
        contents
      end

    end
  end
end
