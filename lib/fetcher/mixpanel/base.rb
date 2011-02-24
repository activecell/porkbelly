require File.expand_path("../mixpanel_client_ext", __FILE__)
require "active_support/core_ext"
require 'json'

module Fetcher
  module Mixpanel
    # Contains share methods for all Mixpanel fetchers.
    module Base
      include Fetcher::Base
      
      # An alias for the ActiveRecord class associate with this fetcher.
      attr_accessor :model_class
      
      MIXPANEL_CONFIG = APIS_CONFIG['mixpanel']
      SITE = "MIXPANEL"
      
      FORMATS = {:json => 'json', :csv => 'csv'}
      TYPES = {:general => 'general', :unique => 'unique', :average => 'average' }
      UNITS = {:hour => 'hour', :day => 'day', :week => 'week', :month =>'month'}
      
      # Limit of the maximum number of values returned by the service.
      DEFAULT_LIMIT = 255
      
      DEFAULT_INTERVAL = 1
      
      # Keys word in the Mixpanel response
      RESPONSE_KEYS = {:legend_size => 'legend_size'}
      
      # Default API URLs
      DEFAULT_API_URLS = {
        'events' => 'events', 
        'events_properties' => 'events/properties',
        'funnels' => 'funnels',
        'funnels_properties' => 'funnels/properties'
      }
      
      #------ Implemetation of abstract Base class ------#
      
      # create logger for mixpanel
      @@logger = BaseLogger.new(File.join(File.dirname(__FILE__), "..", "..", "..", "log", "mixpanel.log"))
      def logger
        @@logger
      end
      
      # Get a list of existence keys from db based on the given credential
      # params:
      #   credential: 
      def existence_keys(credential)
        keys = self.model_class.where("credential = ?", credential).select(:target_id).all
        if(!keys.blank?)
          return keys.collect{|entry| entry.target_id}
        end
        return nil
      end
    
      # Extract unique identifiers from the response(xml/json)
      # params:
      #   response: xml/json response
      def extract_keys(response)
        # Do nothing.
      end
      
      #------  End abstract class implementation. --------#
      
      # Get identification info (such as: api_key, token or username:password)
      def get_api_credentials(credentials_source)
        # Case 1: "<api_key>:<api_secret>"
        if(credentials_source.include?(':'))
          keys = credentials_source.split(':')
          
          if(keys.length == 2)
            api_key = keys[0].strip
            api_secret = keys[1].strip          
            return {:api_key => api_key, :api_secret => api_secret}
          end
          return {} # Return nothing.
        end
        
        # Case 2: get credentials from csv file
        credentials = ::Helpers::Util.hash_from_csv(credentials_source)
        return credentials
      end  
      
      def new_client(credential={})
        @credential = credential.to_options
        
        # Config api URL and version.
        if !MIXPANEL_CONFIG['base_url'].blank?
          MixpanelClientExt.set_base_uri(MIXPANEL_CONFIG['base_url'])
        end
        if !MIXPANEL_CONFIG['version'].blank?
          MixpanelClientExt.set_api_version(MIXPANEL_CONFIG['version'])
        end
        
        @client = MixpanelClientExt.new( 'api_key' => @credential[:api_key], 
                                      'api_secret' => @credential[:api_secret])
      end
      
      def client
        return @client
      end
      
      def currrent_url
        # Track the URL and params.
        @url = client.instance_variable_get(:@uri)
      end
        
      def setup_params(params={})
        params.to_options!
        
        # Set default params.
        if params[:type].blank?
          params[:type] = MIXPANEL_CONFIG['params']['type'] || TYPES[:general]
        end
        
        if params[:unit].blank?
          params[:unit] = MIXPANEL_CONFIG['params']['unit'] || UNITS[:day]
        end
        
        if params[:interval].blank?
          params[:interval] = MIXPANEL_CONFIG['params']['interval'] || DEFAULT_INTERVAL
        end
        
        if params[:format].blank?
          params[:format] = MIXPANEL_CONFIG['params']['format'] || FORMATS[:json]
        end
        
        if params[:limit].blank? || params[:limit].to_i <= 0
          params[:limit] = MIXPANEL_CONFIG['params']['limit'] || DEFAULT_LIMIT
        end
        
        if !params.has_key?(:detect_changes)
          # Auto detect changes          
          params[:detect_changes] = true
        end
        
        if !params.has_key?(:update)
          # Default mode is to update existing record in DB.
          # If this value is false. it means that new record will be inserted instead of being updated.
          params[:update] = true
        end
        
        # Setup optional parameters.
        [:event, :funnel, :name, :values, :bucket].each do |key|
          if !params.has_key?(key)
            params[key] = nil
          end
        end        
        
        return params
      end
      
      def check_changes(data, request_url, target_id)
        url = self.model_class.format_request_url(request_url)
        search_result = self.model_class.where(:target_id => target_id, 
          :request_url => url, :content => data).first
        
        if search_result.blank?
          return true
        end
        
        return false
      end
      
      # Normalize credential, this will raise an ArgumentError if the credential is invalid.
      def normalize_credential!(credential)
        tmp_credential = credential
        if(tmp_credential.is_a?(String))
          begin
            # Detect inline credential or CSV file.
            tmp_credential = self.get_api_credentials(credential)  
          rescue Exception
            raise ArgumentError, "Credential must be in following formats: '<api_key>:<api_secret>' or '<path to a CSV file>'" 
          end
        end
        
        if tmp_credential.is_a?(Hash)
          tmp_credential.to_options # Require active_support/core_ext
          if (tmp_credential[:api_key].blank? || tmp_credential[:api_secret].blank?)
            raise ArgumentError, "This site required api_key and api_secret" 
          end
        end
        
        return tmp_credential
      end
      
      def get_method_url(parent, method='')
        parent = parent.to_s
        method = method.to_s
        if MIXPANEL_CONFIG['apis'][parent].blank?
          return File.join([DEFAULT_API_URLS[parent], method])
        end
        return File.join([MIXPANEL_CONFIG['apis'][parent], method])
      end
    end
  end
end
