require File.expand_path("../../base", __FILE__)
require File.expand_path("../../../models/mixpanel", __FILE__)
require File.expand_path("../../../helpers/util", __FILE__)
require File.expand_path("../../../extensions/mixpanel_client_ext", __FILE__)
require "active_support/core_ext"
require 'json'

module Fetchers
  module Mixpanel
    # Contains share methods for all Mixpanel fetchers.
    module Base
      include Fetchers::Base
      
      SITE = "MIXPANEL"
      FORMATS = {:json => 'json', :csv => 'csv'}
      TYPES = {:general => 'general', :unique => 'unique', :average => 'average' }
      UNITS = {:hour => 'hour', :day => 'day', :week => 'week', :month =>'month'}
      
      # Limit of the maximum number of values returned by the service.
      DEFAULT_LIMIT = 255
      
      # Keys word in the Mixpanel response
      RESPONSE_KEYS = {:legend_size => 'legend_size'}     
      
      #=======================================
      # Implemetation of abstract Base class
      #=======================================
      
      # create logger for mixpanel
      @@logger = BaseLogger.new(File.expand_path("../../../../log/mixpanel.log",__FILE__))
      def logger
        @@logger
      end
      
      # Get identification info (such as: api_key, token or username:password)
      def get_api_credentials(credentials_source)
        # Case 1: "api_key=<key>, api_secret=<secret>"
        if(credentials_source.include?("api_key"))
          keys = credentials_source.split(',')
          api_key = ""
          api_secret = ""
          
          keys.each do |k|
            sub_key = k.split('=')
            value = sub_key[0].strip
            if(value == "api_key")
              api_key = sub_key[1].strip
            elsif(sub_key[0].strip == "api_secret")
              api_secret = sub_key[1].strip
            end
          end
          
          return {:api_key => api_key, :api_secret => api_secret}
        end
        
        # Case 2: get credentials from csv file
        credentials = Util.hash_from_csv(credentials_source)
        return credentials
      end
      
      # Get a list of existence keys from db based on the given credential
      # params:
      #   credential: 
      def existence_keys(credential)
        keys = self.model_class.where(:credential  => credential).select(:target_id).all
        if(!keys.blank?)
          return keys.collect{|entry| entry.target_id}
        end
        return nil
      end
    
      #===================================
      # End abstract class implementation.
      #===================================
      
      def self.support_methods        
        class_variable_get("@@support_methods")
      end
      
      def support_methods
        self.class.class_variable_get("@@support_methods")
      end     
      
      def new_client(credential={})
        @credential = credential.to_options
        @client = MixpanelClientExt.new( 'api_key' => @credential[:api_key], 
                                      'api_secret' => @credential[:api_secret])
      end
      
      def credential
        @credential
      end
      
      def client
        return @client
      end    
      
      def is_method_supported?(method_name)
        if method_name.blank?
          return false
        end
        support_methods.include?(method_name.to_sym)
      end
      
      def currrent_url
        # Track the URL and params.
        @url = client.instance_variable_get(:@uri)
      end
        
      def setup_params(params={})
        params.to_options!
        
        # Set default params.
        if params[:type].blank?
          params[:type] = TYPES[:general]
        end
        
        if params[:unit].blank?
          params[:unit] = UNITS[:day]
        end
        
        if params[:interval].blank?
          params[:interval] = 1
        end
        
        if params[:format].blank?
          params[:format] = FORMATS[:json]
        end
        
        if params[:limit].blank? || params[:limit].to_i <= 0
          params[:limit] = DEFAULT_LIMIT
        end
        
        if !params.has_key?(:detect_changes)
          # Auto detect changes          
          params[:detect_changes] = true
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
        search_result = self.model_class.where(:request_url => url, :content => data).first
        
        if search_result.blank?
          return true
        end
        
        return false
      end
      
      # An alias for the ActiveRecord class associate with this fetcher.
      def model_class
        @model_class
      end
      
      def model_class=(m_class)
        @model_class = m_class
      end
      
    end
  end
end
