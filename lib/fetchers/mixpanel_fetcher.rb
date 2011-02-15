require File.expand_path("../base", __FILE__)
require File.expand_path("../../models/mixpanel", __FILE__)
require "mixpanel_client"
require "active_support/core_ext"
require 'json'

module Fetchers
  module MpFetchers
    # Contains share methods for all MixPanel fetchers.
    module MixpanelFetcherBase
      FORMATS = {:json => 'json', :csv => 'csv'}
      TYPES = {:general => 'general', :unique => 'unique', :average => 'average' }
      UNITS = {:hour => 'hour', :day => 'day', :week => 'week', :month =>'month'}
      DEFAULT_LIMIT = 255
      
      def new_client(credential={})
        @credential = credential.to_options
        @client = Mixpanel::Client.new( 'api_key' => @credential[:api_key], 
                                      'api_secret' => @credential[:api_secret])
      end
      
      def credential
        @credential
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
        
        return params
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
      
      def get_api_credentials(credentials_source)
        
      end    
      
      def parse_credentials(credentials_source)
        # Case 1: "api_key=<key>, api_secret=<secret>"
        
        # Case 2: get credentials from csv file
      end
      
      # fetch data for the given credential
      def fetch_data(data_type, credential, params={})
        begin
          data_type = data_type.to_sym
          data = nil
          
          case data_type
           when :all
            data = fetch_all(credential, params)
           when :events
            data = fetch_events(credential, params)
           when :event_properties
            data = fetch_event_properties(credential, params)
           when :funnels
            data = fetch_funnels(credential, params)
           when :funnel_properties
            data = fetch_funnel_properties(credential, params)
          end
          
          return data  
        rescue Exception => exception
          notify_exception("MIXPANEL", exception)
        end
      end
      
      def fetch_all(credential, params={})
        fetch_events(credential, params)
        fetch_event_properties(credential, params)
        fetch_funnels(credential, params)
        fetch_funnel_properties(credential, params)
      end
      
      def fetch_events(credential, params={})
        begin
          fetcher = EventFetcher.new(credential)
          events = fetcher.all_events(params)
          return events
        rescue Exception => exception
          notify_exception("MIXPANEL", exception)
        end
      end
      
      def fetch_event_properties(credential, params={})
        
      end
      
      def fetch_funnels(credential, params={})
        
      end
      
      def fetch_funnel_properties(credential, params={})
        
      end
    end
    
    class EventFetcher
      include MixpanelFetcherBase
      
      def initialize(credential)
        new_client(credential)
      end     
      
      # Get total, unique, or average data for a set of events over a time period.
      def all_events(params={})
        params = setup_params(params)
        
        #if params[:bucket].blank?
          #params[:bucket] = ""
        #end
        
        # Get names of events.        
        event_names = self.names
        
        data = client.request do
          resource 'events'
          event    event_names.to_s
          type     params[:type]
          unit     params[:unit]
          format   params[:format]
          interval params[:interval]
        end
        
        # Convert to raw data
        data = data.to_json
        
        # Detect data were changed
        changed = true # detect_change(data)
        
        if changed
          # insert data into database
          record = MP::Event.create!(:content => data, :credential => credential[:api_key])
        end
        
        return data
      end
      
      # Get the top events from the last day.
      def top
      
      end
      
      # Get the top event names for a time period.
      def names(params={})
        params = setup_params(params)
        
        data = client.request do
          resource  'events/names'
          type      params[:type]
          unit      params[:unit]
          interval  params[:interval]
          limit     params[:limit]
        end       
        
        return data
      end
      
      # Get the retention data for a set of events.
      def retention
        
      end
    end
  end
end

#Fetchers::MixpanelFetcher.new.fetch_data({:api_key => "4d9b20366fda6e248d8d282946fc988a", :api_secret => "b58997c62b91b19fe039b017ccb6b668"})