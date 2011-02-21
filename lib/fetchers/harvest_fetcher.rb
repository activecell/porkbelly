require File.expand_path("../base", __FILE__)
require File.expand_path("../../models/harvest", __FILE__)
require File.expand_path("../../models/site_tracking", __FILE__)
require 'rest-client'
require 'nokogiri'

module Fetchers
  module HarvestFetcher
    # Base module for harvest fetchers
    module HarvestFetcherBase
      include Base

      SITE = "HARVEST"
      # create logger for Harvest 
      @@logger = BaseLogger.new(File.expand_path("../../../log/harvest.log",__FILE__))
      def logger
        @@logger
      end

      def create_request(credential, request_url, params = {})
        RestClient::Resource.new(request_url, 
                                 :user => credential[:email], 
                                 :password => credential[:password],
                                 :content_type => :xml, 
                                 :accept => :xml,
                                 :params => {})
      end

      def harvest_config
        api_urls["harvest"]
      end

      def get_api_credentials(credentials_source)
        
      end
    end

    # Harvest's client fetcher
    class ClientFetcher
      include HarvestFetcherBase

      TARGET = "Client"

      # Construct a new Harvest's client fetcher
      # params:
      #   credential_source: could be a csv file or a single username/password
      def initialize(credential, subdomain)
        @credential = credential
        @subdomain = subdomain
        @request_url = ""
      end

      # extract the unique key and content from the response and construct to a hash
      def extract_keys(response)
        content_keys = {}
        doc = ::Nokogiri::XML(response)
        doc.xpath("//client").each do |node|
          content_keys["#{node.xpath("./id").first.content}"] = node.to_s
        end
        content_keys
      end

      def send_request(params={})
        request = create_request(@credential, harvest_config["base_url"].gsub(/SUBDOMAIN/, @subdomain), params)
        @request_url = request.to_s
        response = request.get.to_s
      end
      
      # fetch data for a single credential
      def fetch_data
        tracking = ::SiteTracking.where(:site => SITE, :target => TARGET).first
        if tracking
          # check for new data
          logger.info "last update #{tracking.last_request}"
        else
          unless content_keys.nil? and content_keys.empty?
            # insert new records
            response = send_request
            content_keys = extract_keys(response)
            content_keys.each do  |target_id, content|
              Harvest::Client.create!(
                :request_url => @request_url, 
                :content => content, 
                :credential => @credential.to_s, 
                :format => @format,
                :target_id => target_id
              )
            end
            # create new tracking record (each target has only one tracking record)
            ::SiteTracking.create!(:site => SITE, :target => TARGET, :last_request => Time.now)
          end
        end
      end
    end
  end
end
