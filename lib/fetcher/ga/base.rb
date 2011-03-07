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

      def extract_profiles(response)
        entries = Nokogiri::XML(response).search("entry")
        a_ids = Array.new
        wp_ids = Array.new
        profile_names = Array.new
        profile_ids = Array.new
        dxp_table_ids = Array.new
        contents = Array.new
        i = 0
        for i in (i..entries.xpath("//dxp:property").size - 1) do
          if entries.xpath("//dxp:property")[i].attribute('name').value.to_s.eql? "ga:accountId"
            a_ids << entries.xpath("//dxp:property")[i].attribute('value').value.to_i
          end
          if entries.xpath("//dxp:property")[i].attribute('name').value.to_s.eql? "ga:webPropertyId"
            wp_ids << entries.xpath("//dxp:property")[i].attribute('value').value.to_s
          end
          if entries.xpath("//dxp:property")[i].attribute('name').value.to_s.eql? "ga:profileName"
            profile_names << entries.xpath("//dxp:property")[i].attribute('value').value.to_s
          end
          if entries.xpath("//dxp:property")[i].attribute('name').value.to_s.eql? "ga:profileId"
            profile_ids << entries.xpath("//dxp:property")[i].attribute('value').value.to_i
          end
          if entries.xpath("//dxp:property")[i].attribute('name').value.to_s.eql? "dxp:tableId"
            dxp_table_ids << entries.xpath("//dxp:property")[i].attribute('value').value.to_s
          end
        end
        contents = [entries, a_ids, wp_ids, profile_names, profile_ids, dxp_table_ids]
      end

      def extract_goal(response)
        entries = Nokogiri::XML(response).search("entry")
        profile_ids = Array.new
        goal_names = Array.new
        contents = Array.new
        entries.xpath("//ga:goal").each do |goal|
          goal_names << goal.attribute('name').value
        end
        entries.xpath("//dxp:property").each do |dxp_prop|
          profile_ids << dxp_prop.attribute('value').value
        end
        contents = [entries, profile_ids, goal_names]
      end

    end
  end
end
