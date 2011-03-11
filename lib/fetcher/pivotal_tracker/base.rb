require 'cgi'
require 'rubygems'
require 'rest_client'
require 'nokogiri'
require "active_support/core_ext"

module Fetcher
  module PivotalTracker
    module Base
      include Fetcher::Base
      
      PT_CONFIG = APIS_CONFIG['pivotal_tracker']
      SITE = "PIVOTAL_TRACKER"
      BASE_URL = "https://www.pivotaltracker.com/services/v3"
      # Default API URLs
      DEFAULT_API_URLS = {
        'projects' => '/projects', 
        'stories' => '/projects/[PROJECT_ID]/stories',
        'activities' => '/projects/[PROJECT_ID]/activities',
        'memberships' => '/projects/[PROJECT_ID]/memberships',
        'iterations' => '/projects/[PROJECT_ID]/iterations',
        'notes' => '/projects/[PROJECT_ID]/stories/[STORY_ID]/notes',
        'tasks' => '/projects/[PROJECT_ID]/stories/[STORY_ID]/tasks',
      }
      
      CONTENT_TYPE = "application/xml"
      FORMAT = "xml"
      DATE_TIME_FORMAT = "%Y/%m/%d"
      
      attr_accessor :token
      attr_accessor :model_class
      attr_accessor :current_url
      
      #------ Implemetation of abstract Base class ------#
      
      @@logger = BaseLogger.new(File.join(File.dirname(__FILE__), "..", "..", "..", "log", "pivotal_tracker.log"))
      def logger
        @@logger
      end
      
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
      #       + Or, a token string like "e1f12bb1ac3d8f1867278620dda90abb" (recommended for single fetching)
      #       + Or, a string with the format: "<username>:<password>".
      # == Returned value:
      #   + If the params is "token:<api_token>", the returned value will be {:token => "<api_token>"}
      #   + If the params 'credentials_source' is formated as "<username>:<password>",
      #     the returned value will be a hash of {:username => "<username>". :password => "<password>"}
      #   + If the params is a path to a CSV file,
      #     the returned value will be an array of hashes an array of hashes {:token => "<token>"}
      #     Or, an array of hashes {:username => "<username>", :password => "<password>"}
      def get_api_credentials(credentials_source)
        credentials = nil
        credentials_source = credentials_source.strip
        # Case 1: "username:password"
        if(credentials_source.include?(':'))
          values = credentials_source.split(':')
          
          if(values.length == 2)
            username = values[0].strip
            password = values[1].strip
            
            if(username.strip != '' && password.strip != '')
              credentials = {:username => username, :password => password}
            end
          end
        else
          if(File.exists?(credentials_source))
            credentials = ::Helpers::Util.hash_from_csv(credentials_source)
          elsif(!credentials_source.blank?)
            credentials = {:token => credentials_source}
          end
        end
        return credentials
      end
      
      # Retrieve the token needs to get data from Pivotal Tracker service.
      def get_token(username, password)
        response = RestClient.post('https://www.pivotaltracker.com/services/v3/tokens/active',
          :username => username, :password => password)
        self.token= Nokogiri::XML(response.body).search('guid').inner_html
        return self.token
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
        return '' if !options.is_a?(Hash) || options.empty?
        options_strings = []
        # remove options which are not filters, and encode them as such
        [:limit, :offset].each do |o|
          options_strings << "#{CGI.escape(o.to_s)}=#{CGI.escape(options.delete(o))}" if options[o]
        end
        # assume remaining key-value pairs describe filters, and encode them as such.
        filters_string = options.map do |key, value|
          [value].flatten.map {|v| "#{CGI.escape(key.to_s)}%3A#{CGI.escape(v.to_s)}"}.join('&filter=')
        end
        options_strings << "filter=#{filters_string.join('%20')}" unless filters_string.empty?
        return "?#{options_strings.join('&')}"
      end
      
      # Normalize credential, this will raise an ArgumentError if the credential is invalid.
      # == Parameters:
      #   + credential can be: 
      #       - A string that contains path to an CSV file 
      #       - Or a key.
      #       - Or, the string with the format: "<username>:<password>"
      #       - Or, a hash with the format {:username => "<username>", :password => "<password>"}
      #       - Or, a hash with the format {:token => "<token>"}
      # == Returned value:
      #   + A hash of {:api_key => "<api_key>". :api_secret => "<api_secret>"}.
      #   + Or, an array of hashes {:api_key => "<api_key>". :api_secret => "<api_secret>"}
      def normalize_credential!(credential)
        tmp_credential = credential
        if(tmp_credential.is_a?(String))
          begin
            # Detect inline credential or CSV file.
            tmp_credential = self.get_api_credentials(credential)
            raise if tmp_credential.blank?
          rescue Exception
            raise ArgumentError, "Credential must be in following formats: '<username>:<password>', 'token' or '<path to a CSV file>'" 
          end
        end
        
        if tmp_credential.is_a?(Hash)
          tmp_credential.to_options # Require active_support/core_ext
          if ((tmp_credential[:username].blank? || tmp_credential[:password].blank?) &&
                (tmp_credential[:token].blank?))
            raise ArgumentError, "This site required api_key and api_secret" 
          end
        end
        
        return tmp_credential
      end
      
      def fetch(model_class, token, target_api, response_parse_logic, 
                setup_params_logic, support_timestamp = true,
                additional_attrs = {})
        self.model_class = model_class
        
        target = model_class.to_s.split("::").last
        logger.info "Fetching #{target} ..."
        
        target_ids = []
        
        if support_timestamp
          tracking = ::SiteTracking.find_or_initialize_by_site_and_target(SITE, target)
        end
        
        begin
          url = self.combine_url(target_api)
          params = {}
          
          last_request = nil
          if support_timestamp and tracking and tracking.last_request
            last_request = tracking.last_request.strftime(DATE_TIME_FORMAT)
          end
          
          # Call the delegate code to setup time tracking param.
          setup_params_logic.call(last_request, params)
          
          # Send request to Pivotal Tracker.
          logger.info "Basic request URL: #{url}"
          
          response = create_request(token, url, params).get
          
          self.current_url = url
          
          logger.info "====== Full request URL: #{url} ====="
          
          # Call the delegate code to parse the responded data.
          content_keys = response_parse_logic.call(response)

          if content_keys.kind_of?(Hash) and !content_keys.blank?
            content_keys.each do |key, content|
              target_ids << key
              target_entity = model_class.find_or_initialize_by_target_id(key)
              # insert of update target
              attrs = {
                :request_url => url, 
                :content => content, 
                :credential => token, 
                :format => FORMAT
              }
              attrs.merge!(additional_attrs)
              updated = target_entity.update_attributes(attrs)
              
              if updated                
                logger.info "Finish save #{target} with key #{key} to database."
              else
                raise "Fails to save #{target} with key #{key} to database."
              end
            end
            
            # update tracking record for the next fetch
            if support_timestamp
              tracking.update_attributes({:last_request => Time.now})
            end
          end
          
        rescue Exception => exception
          logger.error exception
          logger.error exception.backtrace
          notify_exception(SITE, exception) 
          raise exception
        end
        
        logger.info "Finish fetching #{target}."
        return target_ids
      end
      
      def combine_url(sub_url)
        return File.join(base_url, sub_url)
      end
      
      def get_api_url(name)
        if PT_CONFIG['apis'].blank? || PT_CONFIG['apis'][name].blank?
          return DEFAULT_API_URLS[name]
        end
        
        return PT_CONFIG['apis'][name]
      end
      
      def format_project_url(origin_url, project_id)
        return origin_url.gsub('[PROJECT_ID]', project_id.to_s)
      end
      
      def format_story_url(origin_url, story_id)
        return origin_url.gsub('[STORY_ID]', story_id.to_s)
      end
    end
  end
end
