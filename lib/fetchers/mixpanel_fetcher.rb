require File.expand_path("../base", __FILE__)
require File.expand_path("../../models/mixpanel", __FILE__)
require File.expand_path("../../helpers/util", __FILE__)
require File.expand_path("../../extensions/mixpanel_client_ext", __FILE__)
require "active_support/core_ext"
require 'json'

module Fetchers
  module MpFetchers
    # Contains share methods for all MixPanel fetchers.
    module MixpanelFetcherBase
      SITE = "MIXPANEL"
      FORMATS = {:json => 'json', :csv => 'csv'}
      TYPES = {:general => 'general', :unique => 'unique', :average => 'average' }
      UNITS = {:hour => 'hour', :day => 'day', :week => 'week', :month =>'month'}
      DEFAULT_LIMIT = 255
      
      # Keys word in the Mixpanel response
      RESPONSE_KEYS = {:legend_size => 'legend_size'}
      
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
      
      def self.support_methods
        @@support_methods ||= []
      end
      
      def support_methods
        @@support_methods ||= []
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
        
        if !params.has_key?(:bucket)
          # Auto detect changes          
          params[:bucket] = nil
        end
        
        return params
      end
      
      def check_changes(data, request_url)
        url = MP::Event.format_request_url(request_url)
        search_result = MP::Event.where(:request_url => url, :content => data).first
        
        if search_result.blank?
          return true
        end
        
        return false
      end
    end  
    
    class MixpanelFetcher
      include Base   
      include MixpanelFetcherBase
      
      OPTIONS = [:all, :events, :event_properties, :funnels, :funnel_properties]
      
      # create logger for mixpanel
      @@logger = BaseLogger.new(File.expand_path("../../../log/mixpanel.log",__FILE__))
      def logger
        @@logger
      end
      
      # fetch data for the given credential
      def fetch_data(credential, data_type, params={}, method="all_events")
        begin
          data_type = data_type.to_sym
          data = nil
          
          if data_type != :all
            data = send("fetch_#{data_type}", credential, params, method)
          else
            data = send("fetch_all", credential, params)
          end
          #~ case data_type
           #~ when :all
            #~ data = fetch_all(credential, params)
           #~ when :events
            #~ data = fetch_events(credential, params)
           #~ when :event_properties
            #~ data = fetch_event_properties(credential, params)
           #~ when :funnels
            #~ data = fetch_funnels(credential, params)
           #~ when :funnel_properties
            #~ data = fetch_funnel_properties(credential, params)
          #~ end
          
          return data  
        rescue Exception => exception
          notify_exception(SITE, exception)
        end
      end
      
      def fetch_all(credential, params={})
        fetch_events(credential, params)
        fetch_event_properties(credential, params)
        fetch_funnels(credential, params)
        fetch_funnel_properties(credential, params)
      end
      
      # Valid method names: :all_events, :name, :top, :retention
      def fetch_events(credential, params={}, method_name="all_events")
        puts "Fetching events/#{method_name} from Mixpanel..."
        begin
          fetcher = EventFetcher.new(credential)
          
          # Check supported method.
          if !fetcher.support_methods.include?(method_name)
            method_name = :all_events
          end
          
          # Call the method.
          events = fetcher.send(method_name, params)
          return events
        rescue Exception => exception
          notify_exception(SITE, exception)
        end
      end
      
      def fetch_event_properties(credential, params={}, method_name="all_properties")
        puts "Fetching event/properties/#{method_name} from Mixpanel..."
        begin
          fetcher = EventPropertyFetcher.new(credential)
          
          # Check supported method.
          if !fetcher.support_methods.include?(method_name)
            method_name = :all_properties
          end
          
          # Call the method.
          data = fetcher.send(method_name, params)
          return data
        rescue Exception => exception
          notify_exception(SITE, exception)
        end
      end
      
      def fetch_funnels(credential, params={}, method_name="all_funnels")
        puts "Fetching funnels from Mixpanel..."
        begin
          fetcher = FunnelFetcher.new(credential)
          
          # Check supported method.
          if !fetcher.support_methods.include?(method_name)
            method_name = :all_funnels
          end
          
          # Call the method.
          data = fetcher.send(method_name, params)
          return data
        rescue Exception => exception
          notify_exception(SITE, exception)
        end
      end
      
      def fetch_funnel_properties(credential, params={}, method_name="all_properties")
        puts "Fetching funnel properties from Mixpanel..."
        begin
          fetcher = FunnelPropertyFetcher.new(credential)
          
          # Check supported method.
          if !fetcher.support_methods.include?(method_name)
            method_name = :all_properties
          end
          
          # Call the method.
          data = fetcher.send(method_name, params)
          return data
        rescue Exception => exception
          notify_exception(SITE, exception)
        end
      end
    end
    
    class EventFetcher
      include MixpanelFetcherBase      
      @@support_methods = [:all_events, :names, :top, :retention]
            
      def initialize(credential)
        new_client(credential)
      end     
      
      # Get total, unique, or average data for a set of events over a time period.
      # Parameters:
      #   - params: parameters for the request.
      #   - save_to_db: determine to save the responded data to DB or not.
      def all_events(params={}, save_to_db=true)
        params = setup_params(params)
        
        event_names = []
        if params[:event]
          if params[:event].is_a?(Array)
            event_names += params[:event]
          else
            event_names << params[:event]
          end
        else
          # Get names of events.        
          event_names = self.names(params, false)
        end
        
        data = client.request do
          resource 'events'
          event    event_names.to_s
          type     params[:type]
          unit     params[:unit]
          format   params[:format]
          interval params[:interval]
          bucket   params[:bucket]
        end      
        
        # Format to JSON data.
        json_data = data.to_json       
        
        if save_to_db
          should_save = false # Flag to save the data to DB or not.
          
          # Detect data is empty or not
          is_empty = (data.blank? || data[RESPONSE_KEYS[:legend_size]].to_i <= 0)
          
          if !is_empty && params[:detect_changes]
            # Detect data were changed
            should_save = check_changes(json_data, currrent_url)
          elsif !is_empty
            should_save = true
          end
          
          if should_save
            # insert data into database
            puts "===> insert data into database..."
            record = MP::Event.create!({
              :content => json_data, 
              :format => FORMATS[:json],
              :credential => credential[:api_key],
              :request_url => currrent_url
            })
          end
        end
        return json_data
      end
      
      # Get the top events from the last day.
      # Parameters:
      #   - params: parameters for the request.
      #   - save_to_db: determine to save the responded data to DB or not.
      def top(params={}, save_to_db=true)
        params = setup_params(params)
        
        data = client.request do
          resource 'events/top'
          type     params[:type]
          limit    params[:limit]
          bucket   params[:bucket]
        end
        
        # Format to JSON data.
        json_data = data.to_json
        
        if save_to_db
          should_save = false # Flag to save the data to DB or not.
          
          # Detect data is empty or not
          is_empty = false#(data.blank? || data[RESPONSE_KEYS[:legend_size]].to_i <= 0)
          
          if !is_empty && params[:detect_changes]
            # Detect data were changed
            should_save = check_changes(json_data, currrent_url)
          elsif !is_empty
            should_save = true
          end
          
          if should_save
            # insert data into database
            puts "===> insert data into database..."
            record = MP::Event.create!({
              :content => json_data, 
              :format => FORMATS[:json],
              :credential => credential[:api_key],
              :request_url => currrent_url
            })
          end
        end
        return json_data
      end
      
      # Get the top event names for a time period.
      # Parameters:
      #   - params: parameters for the request.
      #   - save_to_db: determine to save the responded data to DB or not.
      def names(params={}, save_to_db=true)
        params = setup_params(params)
        
        data = client.request do
          resource  'events/names'
          type      params[:type]
          unit      params[:unit]
          interval  params[:interval]
          limit     params[:limit]
          bucket    params[:bucket]
        end       
        
        if save_to_db
          # Detect data is empty or not
          is_empty = (data.blank?)
          
          if !is_empty && params[:detect_changes]
            # Detect data were changed
            should_save = check_changes(data.to_s, currrent_url)
          elsif !is_empty
            should_save = true
          end
          
          if should_save
            # insert data into database
            puts "===> insert data into database..."
            record = MP::Event.create!({
              :content => data, 
              :format => FORMATS[:json],
              :credential => credential[:api_key],
              :request_url => currrent_url
            })
          end
        end
        
        return data
      end
      
      # Get the retention data for a set of events.
      # Parameters:
      #   - params: parameters for the request.
      #   - save_to_db: determine to save the responded data to DB or not.
      def retention(params={}, save_to_db=true)
        params = setup_params(params)
        
        # Get names of events.        
        event_names = self.names
        data = client.request do
          resource 'events/retention'
          event    event_names.to_s
          unit     params[:unit]          
          interval params[:interval]
          format   params[:format]
          bucket   params[:bucket]
        end
        
        # Format to JSON data.
        json_data = data.to_json
        
        if save_to_db
          should_save = false # Flag to save the data to DB or not.
          
          # Detect data is empty or not
          is_empty = false#(data.blank? || data[RESPONSE_KEYS[:legend_size]].to_i <= 0)
          
          if !is_empty && params[:detect_changes]
            # Detect data were changed
            should_save = check_changes(json_data, currrent_url)
          elsif !is_empty
            should_save = true
          end
          
          if should_save
            # insert data into database
            puts "===> insert data into database..."
            record = MP::Event.create!({
              :content => json_data, 
              :format => FORMATS[:json],
              :credential => credential[:api_key],
              :request_url => currrent_url
            })
          end
        end
        return json_data
      end
    end
    
    class EventPropertyFetcher
      include MixpanelFetcherBase      
      @@support_methods = [:all_properties, :top, :values]
      
      def initialize(credential)
        new_client(credential)
      end
      
      # Get total, unique, or average data from a single event property.
      # Parameters:
      #   - params: parameters for the request.
      #   - save_to_db: determine to save the responded data to DB or not.
      def all_properties(params={}, save_to_db=true)
        params = setup_params(params)
        
        property_names = []
        if params[:name]
          if params[:name].is_a?(Array)
            property_names += params[:name]
          else
            property_names << params[:name]
          end
        else
          # Get names of properties.        
          json_property_names = self.top(params, false)
          property_names = JSON.parse(json_property_names).keys
        end        
        
        property_data = []
        
        property_names.each do |proper_name|
          data = client.request do
            resource 'events/properties'
            event    params[:event]
            name     proper_name
            values   params[:values]
            type     params[:type]
            unit     params[:unit]
            format   params[:format]
            interval params[:interval]
            bucket   params[:bucket]
          end
          
          property_data << {:request_url => currrent_url, :content => data}
        end
        
        if save_to_db
          MP::Event.transaction do            
            property_data.each do |p_data|
              should_save = false # Flag to save the data to DB or not.
              
              # Detect data is empty or not
              is_empty = (p_data[:content].blank? || p_data[:content][RESPONSE_KEYS[:legend_size]].to_i <= 0)
              
              json_data = p_data[:content].to_json
              
              if !is_empty && params[:detect_changes]
                # Detect data were changed
                should_save = check_changes(json_data, p_data[:request_url])
              elsif !is_empty
                should_save = true
              end
              
              if should_save
                # insert data into database
                puts "===> insert properties data into database..."            
                record = MP::Event.create!({
                  :content => json_data, 
                  :format => FORMATS[:json],
                  :credential => credential[:api_key],
                  :request_url => p_data[:request_url]
                })
              end
            end
          end
        end
        
        return property_data.to_json
      end
      
      # Get the top properties for an event.
      # Parameters:
      #   - params: parameters for the request.
      #   - save_to_db: determine to save the responded data to DB or not.
      def top(params={}, save_to_db=true)
        params = setup_params(params)
        
        data = client.request do
          resource 'events/properties/top'
          event    params[:event]
          type     params[:type]
          unit     params[:unit]
          interval params[:interval]
          limit    params[:limit]       
          bucket   params[:bucket]
        end
        
        # Format to JSON data.
        json_data = data.to_json
        
        if save_to_db
          should_save = false # Flag to save the data to DB or not.
          
          # Detect data is empty or not
          is_empty = (data.blank?)
          
          if !is_empty && params[:detect_changes]
            # Detect data were changed
            should_save = check_changes(json_data, currrent_url)
          elsif !is_empty
            should_save = true
          end
          
          if should_save
            # insert data into database
            puts "===> insert data into database..."
            record = MP::Event.create!({
              :content => json_data, 
              :format => FORMATS[:json],
              :credential => credential[:api_key],
              :request_url => currrent_url
            })
          end
        end
        return json_data
      end
      
      # Get the top values for a single event property.
      # Parameters:
      #   - params: parameters for the request.
      #   - save_to_db: determine to save the responded data to DB or not.
      def values(params={}, save_to_db=true)
        params = setup_params(params)
      end
    end
    
    class FunnelFetcher
      include MixpanelFetcherBase      
      @@support_methods = [:all_funnels, :names, :dates]
      
      def initialize(credential)
        new_client(credential)
      end
      
      def all_funnels(params={}, save_to_db=true)
      
      end
      
      def names(params={}, save_to_db=true)
      
      end
      
      def dates(params={}, save_to_db=true)
      
      end
    end
    
    class FunnelPropertyFetcher
      include MixpanelFetcherBase      
      @@support_methods = [:all_properties, :names]
      
      def initialize(credential)
        new_client(credential)
      end
      
      def all_properties(params={}, save_to_db=true)
      
      end
      
      def names(params={}, save_to_db=true)
      
      end
    end
  end
end
