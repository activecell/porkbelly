require 'cgi'
require 'rest_client'
require 'nokogiri'

module Fetcher
  module PivotalTracker
    module Base
      include Fetcher::Base
      
      PT_CONFIG = APIS_CONFIG['pivotal_tracker']
      SITE = "PIVOTAL_TRACKER"
      BASE_URL = "https://www.pivotaltracker.com/services/v3"
      CONTENT_TYPE = "application/xml"
      
      attr_accessor :token
      
      @@logger = BaseLogger.new(File.join(File.dirname(__FILE__), "..", "..", "..", "log", "pivotal_tracker.log"))
      def logger
        @@logger
      end
      
      #------ Implemetation of abstract Base class ------#
      
      
      
      #------  End abstract class implementation. --------#
      
      # Get identification info (such as: api_key, token or username:password)
      # == Parameters:
      #   + credentials_source: there are 3 types of options:
      #       + Path to an CSV file. The CSV file must be in one of following formats:
      #         - Contain tokens: (recommended for multiple fetching)
      #             token
      #             token1
      #             token2
      #         - Contain username and password:
      #             username,  password
      #             user1,     password1
      #             user2,     password2
      #       + Or, a string with the format: "token:<api_token>" (recommended for single fetching)
      #       + Or, a string with the format: "<username>:<password>" ,
      # == Returned value:
      #   + If the params is "token:<api_token>", the returned value will be {:token => "<api_token>"}
      #   + If the params 'credentials_source' is formated as "<username>:<password>",
      #     the returned value will be a hash of {:username => "<username>". :password => "<password>"}
      #   + If the params is a path to a CSV file,
      #     the returned value will be an array of hashes an array of hashes {:token => "<token>"}
      #     Or, an array of hashes {:username => "<username>", :password => "<password>"}
      def get_api_credentials(credentials_source)
        credentials = nil
        
        # Case 1: "<api_key>:<api_secret>"
        if(credentials_source.include?('token:'))
        
        elsif(credentials_source.include?(':')) # Case 2: username:password
        
        else # Case 3: read from file
        
        end
        
        credentials = ::Helpers::Util.hash_from_csv(credentials_source)
        
        return credentials
      end
      
      
      # Retrieve the token needs to get data from Pivotal Tracker service.
      def get_token(username, password)
        response = RestClient.post 'https://www.pivotaltracker.com/services/v3/tokens/active', :username => username, :password => password
        token= Nokogiri::XML(response.body).search('guid').inner_html
        return token
      end
      
      def create_request(token, request_url, params = {})        
        # convert params hash to request param string
        options = encode_options(params)
        request_url << options
        logger.info "Create request #{request_url}"       
        
        RestClient::Resource.new(request_url, 
          :headers => {'X-TrackerToken' => token, 'Content-Type' => CONTENT_TYPE}
        )
      end
      
      def base_url
        if PT_CONFIG['base_url'].blank?
          return BASE_URL
        end
        
        PT_CONFIG['base_url']
      end
      
      # Normalize options to params string.
      # Inspired from Pivotal Tracker gem 
      # by Justin Smestad (https://github.com/jsmestad/pivotal-tracker)
      def encode_options(options)
        return nil if !options.is_a?(Hash) || options.empty?
        options_strings = []
        # remove options which are not filters, and encode them as such
        [:limit, :offset].each do |o|
          options_strings << "#{CGI.escape(o.to_s)}=#{CGI.escape(options.delete(o))}" if options[o]
        end
        # assume remaining key-value pairs describe filters, and encode them as such.
        filters_string = options.map do |key, value|
          [value].flatten.map {|v| "#{CGI.escape(key.to_s)}%3A#{CGI.escape(v)}"}.join('&filter=')
        end
        options_strings << "filter=#{filters_string}" unless filters_string.empty?
        return "?#{options_strings.join('&')}"
      end
    end
  end
end
