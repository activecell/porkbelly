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
        event_data = client.request do
          resource method_url #'events'
          event    event_names.to_s
          type     params[:type]
          unit     params[:unit]
          interval params[:interval]
          format   params[:format]
          bucket   params[:bucket]
        end
        
        # Detect event data is empty or not
        is_empty = (event_data.blank? || event_data[RESPONSE_KEYS[:legend_size]].to_i <= 0)
        if save_to_db && !is_empty
          self.model_class.transaction do            
            # Detect data were changed
            target_ids = nil
            if params[:detect_changes]
              target_ids = self.existence_keys(self.credential[:api_key])
            end
            
            # Goal: Store each event in a single record in DB.              
            series_data = event_data['data']['series']
            values_data = event_data['data']['values']
            event_names.each do |event_name|
              event_values = values_data[event_name]
              next if event_values.blank?
              
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
              
              should_save = true # Flag to save the data to DB or not.
              should_update = false # Flag to update the record or not.
              
              if params[:detect_changes] && !target_ids.blank?
                if target_ids.include?(event_name)
                  # The record with given keys existed, check it's content.
                  should_save = check_changes(json_data, current_url, event_name)
                  should_update = true
                else
                  should_save = true # The record does not exist, so insert the new one.
                end
              end
              
              if should_save && should_update && params[:update]
                logger.info "===> Update Mixpanel event '#{event_name}'..."
                self.model_class.update_all(
                  { :content => json_data, 
                    :format => FORMATS[:json],
                    :request_url => current_url
                  },
                  ["target_id = ? AND credential = ?", event_name, credential[:api_key]]
                )
              elsif should_save
                logger.info "===> Insert new Mixpanel event '#{event_name}'..."
                record = self.model_class.create!({
                  :content => json_data, 
                  :target_id  => event_name,
                  :format => FORMATS[:json],
                  :credential => credential[:api_key],
                  :request_url => current_url
                })
              end
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
        data = client.request do
          resource method_url#'events/top'
          type     params[:type]
          limit    params[:limit]
          bucket   params[:bucket]
        end
        
        puts "====== Top event data: #{data} === data class :#{data.class}"
        is_empty = (data.blank? || data['events'].blank?)
        if save_to_db && !is_empty
          target_ids = nil
          if params[:detect_changes]
            target_ids = self.existence_keys(self.credential[:api_key])
          end
          
          
          self.model_class.transaction do
            puts "====== data['events']=#{data["events"]}, #{data["events"].class}"
            data['events'].each do |event|
              target_id = event['event']
              # Format to JSON data.
              json_data = {:events => event}.to_json
              
              should_save = false # Flag to save the data to DB or not.
              should_update = false
              
              # Detect data is empty or not
              is_event_empty = event.blank?
              
              if !is_event_empty && params[:detect_changes] && !target_ids.blank?
                # Detect data were changed
                if target_ids.include?(target_id)
                  # The record with given keys existed, check it's content.
                  should_save = check_changes(json_data, current_url, target_id)
                  should_update = true
                else
                  should_save = true # The record does not exist, so insert the new one.
                end
              elsif !is_empty
                # Insert a new record.
                should_save = true
              end
              
              if should_save && should_update && params[:update]
                logger.info "===> Update Mixpanel event/top '#{target_id}'..."
                self.model_class.update_all(
                  { :content => json_data, 
                    :format => FORMATS[:json],
                    :request_url => current_url
                  },
                  ["target_id = ? AND credential = ?", target_id, credential[:api_key]]
                )
              elsif should_save
                logger.info "===> Insert new Mixpanel events/top '#{target_id}'..."
                record = self.model_class.create!({
                  :content => json_data, 
                  :target_id => target_id,
                  :format => FORMATS[:json],
                  :credential => credential[:api_key],
                  :request_url => current_url
                })
              end
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
        self.model_class = ::Mixpanel::Event
        
        method_url = get_method_url('events', 'names')
        data = client.request do
          resource  method_url #'events/names'
          type      params[:type]
          unit      params[:unit]
          interval  params[:interval]
          limit     params[:limit]
          bucket    params[:bucket]
        end
        
        puts "========== Event names: #{data}, save = #{save_to_db} ========"
        
        if save_to_db && !data.blank?
          self.model_class.transaction do
            target_ids = nil
            if params[:detect_changes]
              target_ids = self.existence_keys(self.credential[:api_key])
            end
            
            data.each do |name|  
              should_save = false
              if params[:detect_changes] && !target_ids.blank?
                should_save = !target_ids.include?(name)
              else
                should_save = true
              end
              
              if should_save
                # insert data into database
                logger.info "===> Insert event name '#{name}' ..."
                record = self.model_class.create!({
                  :content => name, 
                  :target_id => name,
                  :format => FORMATS[:json],
                  :credential => credential[:api_key],
                  :request_url => current_url
                })
              end
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
        data = client.request do
          resource method_url #'events/retention'
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
            should_save = check_changes(json_data, current_url, current_url)
          elsif !is_empty
            should_save = true
          end
          
          if should_save
            logger.info "===> Insert data of events/retention ..."
            record = self.model_class.create!({
              :content => json_data,
              :target_id => current_url,
              :format => FORMATS[:json],
              :credential => credential[:api_key],
              :request_url => current_url
            })
          end
        end
        return data
      end
    end
  end
end
