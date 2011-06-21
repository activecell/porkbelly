module Fetcher
  module Mixpanel
    # Event module contains methods to interact with 
    # the API endpoint http://mixpanel.com/api/2.0/events/ of Mixpanel
    module Event
      include Fetcher::Mixpanel::Base
      
      # List of supported methods in this module.
      @@event_supported_methods = [
        :fetch_all_events, :fetch_event_names, 
        :fetch_top_event, :fetch_event_retention]
      
      # Get total, unique, or average data for a set of events over a time period.
      # == API reference:
      #   http://mixpanel.com/api/docs/guides/api/v2#events-default.
      # == Parameters:
      #   + params: hash of parameters for the request.
      #       - params[:event]: single or array of events to fetch. 
      #           If no event is specified, the method will automatically 
      #           get all events (within a time interval)
      #       Two special parameters: 
      #         - params[:detect_changes]: specify to detect changes or not. Default value is true.
      #         - params[:update]: specify to update the existing record or insert the new one. 
      #             set 'true' to update existing record and 'false' for insert new record (anyway).
      #             Default value is 'true'
      #             This param can combine with params[:detect_changes] to just insert 
      #             or update data if there is change
      #   + save_to_db: determine to save the responded data to DB or not.
      #                 Default value is 'true'
      # == Returned value:
      #   A hash object parsed from the returned data of Mixpanel service.
      def fetch_all_events(params={}, save_to_db=true)
        params = setup_params(params)
        self.model_class = ::Mixpanel::Event
        
        event_names = []
        if params[:event]
          if params[:event].is_a?(Array)
            event_names += params[:event]
          else
            event_names << params[:event]
          end
        else
          # Get names of events.
          event_names = self.fetch_event_names(params, false)
        end
        
        # Get events data.
        method_url = get_method_url('events')
        
        request_params = self.select_params(params, [:type, :unit, :interval, :format, :bucket])
        request_params[:resource] = method_url
        request_params[:event] = event_names.to_json
        puts ">>>>>>>>>>>>>>>>> #{request_params.inspect}"        
        event_data = send_request(request_params)
        puts ">>>>>>>>>>>>>>>>> #{event_data}"
        # Detect event data is empty or not
        is_empty = (event_data.blank? || event_data[RESPONSE_KEYS[:legend_size]].to_i <= 0)
        if save_to_db && !is_empty
          self.model_class.transaction do            
            # Get all target ids existing in DB, in order to detect data was changed or not.
            target_ids = get_target_ids(params)
            
            # Sample data:
            # {'data': {'series': ['2010-05-29',
            #                     '2010-05-30',
            #                     '2010-05-31',
            #                     ],
            #          'values': {'account-page': {'2010-05-30': 1,},
            #                     'splash features': {'2010-05-29': 6,
            #                                         '2010-05-30': 4,
            #                                         '2010-05-31': 5,
            #                                        }
            #                    }
            #        },
            # 'legend_size': 2}

            # Goal: Store each event in a single record in DB.              
            series_data = event_data['data']['series']
            values_data = event_data['data']['values']
            event_names.each do |event_name|
              event_values = values_data[event_name]
              next if event_values.blank?
              
              # Get only series related to the event.
              event_series = event_values.keys & series_data

              # Keep the original format of the event data (based on Mixpanel API spec).
              origin_data = {
                :data => {
                  :series => event_series, 
                  :values => {event_name => event_values}
                },
                :legend_size => 1
              }
              
              # Format hash to JSON.
              json_data = origin_data.to_json
              
              self.insert_or_update(params, target_ids, 
                event_name, json_data)
            end
          end
        end
        return event_data
      end
      
      # Get the top events from the last day.
      # == API reference:
      #   http://mixpanel.com/api/docs/guides/api/v2#events-top.
      # == Parameters:
      #   + params: hash of parameters for the request.
      #       Two special parameters: 
      #         - params[:detect_changes]: specify to detect changes or not. Default value is true.
      #         - params[:update]: specify to update the existing record or insert the new one. 
      #             set 'true' to update existing record and 'false' for insert new record (anyway).
      #             Default value is 'true'
      #             This param can combine with params[:detect_changes] to just insert 
      #             or update data if there is change
      #   + save_to_db: determine to save the responded data to DB or not.
      #                 Default value is 'true'
      # == Returned value:
      #   A hash object parsed from the returned data of Mixpanel service.
      def fetch_top_events(params={}, save_to_db=true)
        params = setup_params(params)
        self.model_class = ::Mixpanel::Event
        
        method_url = get_method_url('events', 'top')
        request_params = self.select_params(params, [:type, :limit, :bucket])
        request_params[:resource] = method_url
        
        data = send_request(request_params)
        
        is_empty = (data.blank? || data['events'].blank?)
        if save_to_db && !is_empty
          target_ids = get_target_ids(params)        
          
          self.model_class.transaction do
            data['events'].each do |event|
              target_id = event['event']
              # Format to JSON data.
              json_data = {:events => event}.to_json
              
              self.insert_or_update(params, target_ids, 
                target_id, json_data)
            end
          end         
        end
        return data
      end
      
      # Get the top event names for a time period.
      # == API reference:
      #   http://mixpanel.com/api/docs/guides/api/v2#events-names
      # == Parameters:
      #   + params: hash of parameters for the request.
      #       Two special parameters: 
      #         - params[:detect_changes]: specify to detect changes or not. Default value is true.
      #         - params[:update]: specify to update the existing record or insert the new one. 
      #             set 'true' to update existing record and 'false' for insert new record (anyway).
      #             Default value is 'true'
      #             This param can combine with params[:detect_changes] to just insert 
      #             or update data if there is change
      #   + save_to_db: determine to save the responded data to DB or not.
      #                 Default value is 'true'
      # == Returned value:
      #   An array of events' names.
      def fetch_event_names(params={}, save_to_db=true)
        params = setup_params(params)
        
        # Mixpanel does not support tracking events' names were changed.
        params[:update] = false
        
        self.model_class = ::Mixpanel::Event
        
        method_url = get_method_url('events', 'names')
        request_params = self.select_params(params, [:type, :unit, :interval, 
          :limit, :bucket])
        request_params[:resource] = method_url
        
        data = send_request(request_params)
        
        if save_to_db && !data.blank?
          self.model_class.transaction do
            target_ids = get_target_ids(params)
            
            data.each do |name|
              self.insert_or_update(params, target_ids, 
                name, name)
            end
          end
        end
        return data
      end
            
      # Get the retention data for a set of events.
      # == API reference:
      #   http://mixpanel.com/api/docs/guides/api/v2#events-retention
      # == Parameters:
      #   + params: hash of parameters for the request.
      #       - params[:event]: single or array of events to fetch. If no event is specified.
      #           The method will automatically get all event (within a time interval)
      #       Two special parameters: 
      #         - params[:detect_changes]: specify to detect changes or not. Default value is true.
      #         - params[:update]: specify to update the existing record or insert the new one. 
      #             set 'true' to update existing record and 'false' for insert new record (anyway).
      #             Default value is 'true'
      #             This param can combine with params[:detect_changes] to just insert 
      #             or update data if there is change
      #   + save_to_db: determine to save the responded data to DB or not.
      #                 Default value is 'true'
      # == Returned value:
      #   A hash object parsed from the returned data of Mixpanel service.
      def fetch_event_retention(params={}, save_to_db=true)
        params = setup_params(params)
        self.model_class = ::Mixpanel::Event
        
        # Get names of events. 
        event_names = []
        if params[:event]
          if params[:event].is_a?(Array)
            event_names += params[:event]
          else
            event_names << params[:event]
          end
        else
          # Get names of events.
          event_names = self.fetch_event_names(params, false)
        end
        
        method_url = get_method_url('events', 'retention')
        request_params = self.select_params(params, [:unit, :interval, 
          :format, :bucket])
        request_params[:resource] = method_url
        request_params[:event] = event_names.to_json
        
        data = send_request(request_params)
        
        if save_to_db && !data.blank?
          self.insert_or_update(params, nil, current_url, data.to_json)
        end
        return data
      end
    end
  end
end
