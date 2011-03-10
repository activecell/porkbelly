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
      
      # Supported format of returned data of the Mixpanel service.
      FORMATS = {:json => 'json', :csv => 'csv'}
      
      # The analysis type you would like to get data for,
      # such as general, unique, or average events. 
      TYPES = {:general => 'general', :unique => 'unique', :average => 'average' }
      
      # The unit of measurement to determine the level of granularity of the data you get back.
      UNITS = {:hour => 'hour', :day => 'day', :week => 'week', :month =>'month'}
      
      # Limit of the maximum number of values returned by the service.
      DEFAULT_LIMIT = 255
      
      # The default number of "units" to return data for - hours, days, weeks, or months. 
      DEFAULT_INTERVAL = 1
      
      # Keys words in the Mixpanel response
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
      # == Parameters:
      #   |+ credential: the value of api_key.
      def existence_keys(credential)
        keys = self.model_class.where("credential = ?", credential).select(:target_id).all
        if(!keys.blank?)
          return keys.collect{|entry| entry.target_id}
        end
        return nil
      end
      
      #------  End abstract class implementation. --------#
      
      # Get identification info (such as: api_key, token or username:password)
      # == Parameters:
      #   + credentials_source: a string that contains:
      #       - Path to an CSV file. The CSV file must be in this format:
      #         api_key,  api_secret
      #         key1,     secret1
      #         key2,     secret2
      #       - Or, the string with the format: "<api_key>:<api_secret>"  
      # == Returned value:
      #   + If the params 'credentials_source' is formated as "<api_key>:<api_secret>",
      #     the returned value will be a hash of {:api_key => "<api_key>". :api_secret => "<api_secret>"}
      #   + If the params is a path to a CSV file,
      #     the returned value will be an array of hashes {:api_key => "<api_key>", :api_secret => "<api_secret>"}
      def get_api_credentials(credentials_source)
        # Case 1: "<api_key>:<api_secret>"
        if(credentials_source.include?(':'))
          keys = credentials_source.split(':')
          
          if(keys.length == 2)
            api_key = keys[0].strip
            api_secret = keys[1].strip
            
            if(api_key.strip != '' && api_secret.strip != '')
              return {:api_key => api_key, :api_secret => api_secret}
            end
          end
          return {} # Return nothing.
        end
        
        # Case 2: get credentials from csv file
        credentials = ::Helpers::Util.hash_from_csv(credentials_source)
        return credentials
      end
      
      # Create new Mixpanel client.
      # The API URL and API version will be automactically set.
      # == Paramaters:
      #   + credential = {:api_key => "<api_key>", :api_secret => "<api_secret>"}
      # == Returned value:
      #   An instance of MixpanelClientExt.
      def new_client(credential={})
        if !credential.blank?
          @credential = credential.to_options
        end
        
        # Config api URL and version.
        if !MIXPANEL_CONFIG['base_url'].blank?
          MixpanelClientExt.set_base_uri(MIXPANEL_CONFIG['base_url'])
        end
        if !MIXPANEL_CONFIG['version'].blank?
          MixpanelClientExt.set_api_version(MIXPANEL_CONFIG['version'])
        end
        
        @client = MixpanelClientExt.new('api_key' => @credential[:api_key], 
                                      'api_secret' => @credential[:api_secret])
      end
      
      # Return the currrent Mixpanel client.
      def client
        return @client
      end
      
      # Return the currrent request URL was send by the Mixpanel client.
      def current_url
        # Track the URL and params.
        @url = client.instance_variable_get(:@uri)
      end
      
      # Setup and prepare default (required) parameters for 
      # the request to Mixpanel API service.
      # NOTE: all parameters are specified by Mixpanel Data API (http://mixpanel.com/api/docs/guides/api/v2),
      #       except two special params :detect_changes and :update are our custom params.
      # To avoid error when use the params (returned by this method) with method 'send_request()',
      # you should select necessary params by calling the method 'select_params()',
      # then pass the value to the 'send_request()' method
      # == Parameters:
      #   + params: hash containing your optional parameters need preparing.
      # == Returned value:
      #   The formated params hash.
      def setup_params(params={})
        params.to_options!
        
        # Set Mixpanel params.
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
        
        # Setup optional parameters.
        [:event, :funnel, :name, :values, :bucket].each do |key|
          if !params.has_key?(key)
            params[key] = nil
          end
        end    
        
        # End setup Mixpanel params.
        
        # Setup our custom params
        if !params.has_key?(:detect_changes)
          # Auto detect changes          
          params[:detect_changes] = true
        end
        
        if !params.has_key?(:update)
          # Default mode is to update existing record in DB.
          # If this value is false. it means that new record will be inserted instead of being updated.
          params[:update] = true
        end
        
        # End custom params.
        
        return params
      end
      
      # Select only necessary parameters in the parent hash of params.
      # == Parameters:
      #   + params: the origin hash of parameters. This hash can contains a great number of unnecessary parameters.
      #   + keys: an array of names (or keys) of your necessary parameters.
      # == Returned value:
      #   A new hash.
      def select_params(params, keys)
        params.select {|k,v| keys.include?(k)}
      end
      
      # Send request to Mixpanel API service by using MixpanelClient.
      # == Parameters:
      #   + A hash whose keys are matched with supported parameters of Mixpanel Client.
      # == Returned value:
      #   The response from Mixpanel service.
      def send_request(params)        
        str_block = ""
        params.each{|method, value| 
          if value.nil?
            str_block << "#{method} nil \n"
          else
            str_block << "#{method} '#{value}'\n"
          end
        }
        
        client.request do
          eval(str_block)
        end
      end
      
      # Check data associate with the 'target_id' and 'request_url' was changed or not.
      # This method will compare the passed 'data' to the existing data in DB.
      # == Parameters:
      #   + data: data (is usually a string in JSON or CSV).
      #   + request_url: The URL that was sent to get the data.
      #   + target_id: a key to identify the data (such as event's id or event's name, etc.)
      def check_changes(data, request_url, target_id)
        url = self.model_class.format_request_url(request_url)
        search_result = self.model_class.where(:target_id => target_id, 
          :request_url => url, :content => data).first
        
        if search_result.blank?
          return true
        end
        
        return false
      end
      
      # Gets collection of IDs
      # == Parameters:
      #   + params: a hash. Required item: params[:detect_changes] = true (or false)
      def get_target_ids(params)
        if params[:detect_changes]
          return self.existence_keys(self.credential[:api_key])
        end
      end
      
      def insert_or_update(logic_params, target_ids_array, target_id, data, model_attrs={})
        model_attrs ||= {}
                
        is_empty = data.blank?
        should_save = true # Flag to save the data to DB or not.
        should_update = false # Flag to update the record or not.
        
        # --------------------------
        # Logic code to setup value for two flags should_save & should_update.
        # -------------------------
        
        # Get the request url in the model params or current url.
        url = (model_attrs && !model_attrs[:request_url].blank? ?
                model_attrs[:request_url] : self.current_url)
        
        if !is_empty && logic_params[:detect_changes] && 
            !target_ids_array.blank?
          if target_ids_array.include?(target_id)               
            # Detect data were changed        
            should_save = check_changes(data, url, target_id)
            should_update = true
          else
            should_save = true
          end
        elsif !is_empty
          should_save = true
        end

        # --------------------------
        # Perform insert, update or nothing ;)
        # --------------------------
        if should_save && should_update && logic_params[:update]
          logger.info "===> Update #{self.model_class}: '#{target_id}'..."
          self.model_class.update_all(
            { :content      => data, 
              :format       => logic_params[:format],
              :request_url  => url
            },
            ["target_id = ? AND credential = ?", target_id, credential[:api_key]]
          )
        elsif should_save
          logger.info "===> Insert new #{self.model_class} ..." 
          basic_attrs = {
            :content      => data, 
            :target_id    => target_id,
            :format       => logic_params[:format],
            :credential   => credential[:api_key],
            :request_url  => url
          }      
          basic_attrs.merge!(model_attrs)          
          self.model_class.create!(basic_attrs)
        end
      end
      
      # Normalize credential, this will raise an ArgumentError if the credential is invalid.
      # == Parameters:
      #   + credential can be: 
      #       - A string that contains path to an CSV file.
      #       - Or, the string with the format: "<api_key>:<api_secret>"
      #       - Or, a hash with the format {:api_key => "<api_key>", :api_secret => "<api_secret>"}
      # == Returned value:
      #   + A hash of {:api_key => "<api_key>". :api_secret => "<api_secret>"}.
      #   + Or, an array of hashes {:api_key => "<api_key>". :api_secret => "<api_secret>"}
      # == Exception:
      #   An ArgumentError will be raise if the credential is not valid.
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
      
      # Get the url to the API method.
      # == Parameters:
      #   + parent: the API event point name(such as events, events_properties,...)
      #       Currenct supported endpoint's name are: events, events_properties, funnels and funnels_properties.
      #    + method: the sub method of the endpoint.
      # == Examples:
      #   get_method_url('events', 'top') #=> events/top
      # It sounds silly! But the purpose of this method is 
      # to deal with the changing of API's URL.
      def get_method_url(parent, method='')
        parent = parent.to_s
        method = method.to_s
        if MIXPANEL_CONFIG['apis'].blank? || MIXPANEL_CONFIG['apis'][parent].blank?
          return File.join([DEFAULT_API_URLS[parent], method])
        end
        return File.join([MIXPANEL_CONFIG['apis'][parent], method])
      end
    end
  end
end
