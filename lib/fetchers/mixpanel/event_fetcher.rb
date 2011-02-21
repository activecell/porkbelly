module Fetchers
  module Mixpanel
    class EventFetcher
      include Fetchers::Mixpanel::Base
      
      @@support_methods = [:all_events, :names, :top, :retention]
            
      def initialize(credential)
        new_client(credential)
        self.model_class = MP::Event
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
        
        # Get events data.
        event_data = client.request do
          resource 'events'
          event    event_names.to_s
          type     params[:type]
          unit     params[:unit]
          interval params[:interval]
          format   params[:format]
          bucket   params[:bucket]
        end
        
        params[:event] = event_names           
        
        if save_to_db
          self.model_class.transaction do
            # 
            # Begin saving events.
            #      
            
            # Detect event data is empty or not
            is_empty = (data.blank? || data[RESPONSE_KEYS[:legend_size]].to_i <= 0)
            
            if !is_empty
              # Detect data were changed
              target_ids = self.existence_keys(credential)
              
              # Goal: Store each event in a single record in DB.              
              series_data = event_data['data']['series']
              values_data = event_data['data']['values']
              event_names.each do |event_name|
                event_values = values_data[event_name]
                event_series = event_values.keys & series_data
                
                # Keep the original format of the event data (based on Mixpanel API spec).
                origin_data = {
                  :data => {
                    :series => event_series, 
                    :values => {event_name => event_values}
                  },
                  :legend_size => 1
                }
                
                should_save = false # Flag to save the data to DB or not.
                if params[:detect_changes]
                  should_save = check_changes(json_data, currrent_url)
                end
              end           
            end
            
            #
            # Begin saving event's associate data.
            #
            
            # Get event retention values.
            event_retentions = self.retention(params, save_to_db)
            
            property_fetcher = EventPropertyFetcher.new(self.credential)
            
            # Get events property data.
            property_data = property_fetcher.all_properties(params, save_to_db)
          end         
          
          
          if should_save
            logger.info "===> Insert data of events..."
            record = self.model_class.create!({
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
            logger.info "===> Insert data of events/top ..."
            record = self.model_class.create!({
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
          json_data = data.to_json
          
          if !is_empty && params[:detect_changes]
            # Detect data were changed
            should_save = check_changes(json_data, currrent_url)
          elsif !is_empty
            should_save = true
          end
          
          if should_save
            # insert data into database
            logger.info "===> Insert data of events/names ..."
            record = self.model_class.create!({
              :content => json_data, 
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
            logger.info "===> Insert data of events/retention ..."
            record = self.model_class.create!({
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
  end
end
