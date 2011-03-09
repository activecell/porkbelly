require 'cgi'
require 'uri'
require 'rest_client'
require "active_support/core_ext"
require 'json'
require 'rubygems'
require 'nokogiri'
require 'rforce' # RForce will auto-detect and use Nokogiri as its parser.

module Fetcher
  module Salesforce
    module Base
      include Fetcher::Base
      
      VERSION = "21.0"
      SF_CONFIG = APIS_CONFIG['salesforce']
      SITE = "SALESFORCE"
      LOGIN_URL = "https://login.salesforce.com/services/Soap/u/#{VERSION}"
      
      # Salesforce supports JSON and XML format. JSON is the default.
      # Change the response data format by setting the HTTP ACCEPT header in the request.
      FORMATS = {:json => 'application/json', :xml => 'application/xml'}
      
      # This string to store the session id or token (when using OAuth).
      attr_accessor :session_id
      
      # Current request URL.
      attr_accessor :current_url
      
      # Login URL.
      attr_accessor :login_url
      
      # Hash contain the information returned by Salesforce server when logging to the system.
      attr_accessor :login_info
      
      # Current Salesforce API version.
      attr_accessor :api_version
      
      # Contain the URL to the server instance, such as: 'https://na9.salesforce.com'
      attr_accessor :server_instance_url
      
      # Contain only the instance name of the Salesforce server, such as: 'n9'
      attr_accessor :server_instance_name
      
      # The content type format will be returned by Salesforce service.
      # Allowed value are 'application/json' and 'application/xml'.
      attr_accessor :content_type
      
      # Keys to identify we are using Session id authorization.
      SESSIONID_AUTH = ['username', 'password', 'token']
      
      # Keys to identify we are using Session id authorization.
      OPEN_AUTH = ['consumer_key', 'consumer_secret', 'callback_url']
      
      @@logger = BaseLogger.new(File.join(File.dirname(__FILE__), "..", "..", "..", "log", "salesforce.log"))
      def logger
        @@logger
      end
      
      def get_api_credentials(credentials_source)
      
      end
      
      def normalize_credential!(credential)
      
      end
      
      # Login to Salesforce server and return the session id.
      # == Parameters
      #   + username: your username (usually looks like an email address)
      #   + password: your password.
      #   + token: the security token. You can get the security token in: 
      #       Salesforce > 'Your Account Name' > Setup > My Personal Information > Reset My Security Token
      #     After clicking 'Reset Security Token', you will receive an email containing the token.
      def login(username, password, token)
        self.login_url ||= self.config_login_url        
        binding = RForce::Binding.new self.login_url
        
        self.login_info = binding.login username, (password + token)
        
        if(login_info && login_info[:loginResponse] && login_info[:loginResponse][:result])
          self.session_id = login_info[:loginResponse][:result][:sessionId]
          server_url = login_info[:loginResponse][:result][:serverUrl]
          self.detect_server_instance(server_url)
        end
        
        return self.session_id
      end
      
      def create_request(session_id, request_url, params = {})
        options = hash_to_param_string(params)
        request_url << "?" << options       
        self.session_id = session_id
        
        self.content_type ||= self.config_content_type 
        
        logger.info "Create request #{request_url}"       
        
        RestClient::Resource.new(request_url, 
          :headers => {
            "Accept" => self.content_type, 
            "Authorization" => "OAuth #{self.session_id}",
            #"X-PrettyPrint" => 1
          }
        )
      end
      
      def fetch(object_name, session_id, api_url, setup_params_logic, 
                response_parse_logic, model_logic, support_timestamp = true)
        self.model_class = model_class
        
        target = object_name #model_class.to_s.split("::").last
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
              
              model_logic.call(key)
            end
            
            # update tracking record for the next fetch
            if support_timestamp
              tracking.update_attributes({:last_request => Time.now})
            end
          end
          
        rescue Exception => exception
          raise exception
        end
        
        logger.info "Finish fetching #{target}."
        return target_ids
      end
      
      # Detect the server url used to combine with other URL to make the request.
      # After logging in, SF service will respond a SOAP message containing an URL like this:
      #   https://na9-api.salesforce.com/services/Soap/u/21.0/00DE0000000HuxM
      # However, we cannot use this URL for REST API. Our necessary URL is:
      #   https://na9.salesforce.com/services/data/...
      # The purpose of this method is to return the necessary URL.
      # == Parameters
      #   +server_url: A server URL returned after logging in to Salesforce.
      #     EX: https://na9-api.salesforce.com/services/Soap/u/21.0/00DE0000000HuxM
      # == Returned value:
      #   Return the portion of server_url.
      #     EX: https://na9-api.salesforce.com
      def detect_server_instance(server_url)
        uri = URI.parse(server_url)
        parts = uri.host.split("-")
        self.server_instance_name = parts[0]
        self.server_instance_url = "#{uri.scheme}://#{server_instance_name}.salesforce.com" 
        return self.server_instance_url       
      end
      
      # Detect and setup the Salesforce API version.
      def config_api_version
        self.api_version = (SF_CONFIG['version'].blank? ? VERSION : SF_CONFIG['version'])
      end
      
      # Detect and setup the login URL. This is the most important URL!
      def config_login_url
        if SF_CONFIG['login_url'].blank?
          return LOGIN_URL
        end
        version = config_api_version       
        self.login_url = SF_CONFIG['login_url'].gsub('[VERSION]', version)
      end
      
      # Detect and setup the content type format will be returned by Salesforce services.
      def config_content_type
        format = SF_CONFIG['format']
        if format.blank? || !FORMATS.keys.include?(format.to_sym)
          return self.content_type = FORMATS[:json]
        end
        
        return self.content_type = FORMATS[format.to_sym]
      end
      
      # Setup basic environment for the object.
      def setup_env        
        config_api_version
        config_login_url
        config_content_type
      end
      
      # Combine the server instance URL with the sub URL.
      def combine_url(sub_url)
        return File.join(self.server_instance_url, sub_url)
      end
    end
  end
end
