module Fetcher
  module Mixpanel
    # EventProperty module contains methods to interact with 
    # the API endpoint http://mixpanel.com/api/2.0/events/properties of Mixpanel
    module EventProperty
      include Fetcher::Mixpanel::Base
      
      # List of supported methods in this module.
      @@event_property_supported_methods = [
        :fetch_all_properties, :fetch_top_properties, :fetch_top_property_values]
            
      # Get total, unique, or average data from a single or an array of event properties.
      # == API reference:
      #   http://mixpanel.com/api/docs/guides/api/v2#event-properties-default
      # == Parameters:
      #   + params: hash of parameters for the request.
      #       - params[:name]: single or array of properties to fetch. If no property is specified,
      #           the method will automatically get all properties (within a time interval)
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
      #   An array of hash object in this structure:
      #   [{
      #      :target_id => 'property name', 
      #      :request_url => 'http://mixpanel.com/api/2.0/events/properties?name=feature...', 
      #      :content => 'hash containing property's data'
      #    },
      #    ...
      #   ]      
      def fetch_all_properties(params={}, save_to_db=true)
        params = setup_params(params)
        self.model_class = ::Mixpanel::EventProperty
        
        property_names = []
        if params[:name]
          if params[:name].is_a?(Array)
            property_names += params[:name]
          else
            property_names << params[:name]
          end
        else
          # Get names of properties.        
          property_names = self.fetch_top_properties(params, false)
          property_names = property_names.keys
        end        
        
        property_data = []
        
        request_params = self.select_params(params, [:event, :values, :type, 
            :unit, :interval, :format, :bucket])
        request_params[:resource] = get_method_url('events_properties')
        
        property_names.each do |proper_name|
          request_params[:name] = proper_name
          data = send_request(request_params)
          property_data << {
            :target_id => proper_name, 
            :request_url => current_url, 
            :content => data
          }
        end
        
        if save_to_db && !property_data.blank?
          self.model_class.transaction do
            target_ids = get_target_ids(params)
            
            property_data.each do |p_data|
              # Detect data is empty or not
              is_empty = (p_data[:content].blank? || p_data[:content][RESPONSE_KEYS[:legend_size]].to_i <= 0)
              
              next if is_empty
              
              attrs = {
                :event_name => params[:event],
                :request_url => p_data[:request_url]
              }
              self.insert_or_update(params, target_ids, 
                p_data[:target_id], p_data[:content].to_json, attrs)             
            end
          end
        end
        
        return property_data
      end
      
      # Get the top properties for an event.
      # == API reference:
      #   http://mixpanel.com/api/docs/guides/api/v2#event-properties-top
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
      def fetch_top_properties(params={}, save_to_db=true)
        params = setup_params(params)
        self.model_class = ::Mixpanel::EventProperty
        
        request_params = self.select_params(params, [:event, :type, :unit, 
          :interval, :limit, :bucket])
        request_params[:resource] = get_method_url('events_properties', 'top')
        
        data = send_request(request_params)
        
        if save_to_db && !data.blank?
          self.model_class.transaction do
            target_ids = get_target_ids(params)
            
            data.keys.each do |property_name|
              next if data[property_name].blank?
              
              json_data = {property_name => data[property_name]}.to_json
              attrs = {
                :event_name => params[:event]
              }
              
              self.insert_or_update(params, target_ids, 
                  property_name, json_data, attrs)                
            end
          end
        end
        return data
      end
      
      # Get the top values for a single event property.
      # == API reference:
      #   http://mixpanel.com/api/docs/guides/api/v2#event-properties-values
      # == Parameters:
      #   + params: hash of parameters for the request.
      #       - params[:name]: single or array of properties to fetch.
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
      #   An array of hash object parsed from the returned data of Mixpanel service.
      def fetch_top_property_values(params={}, save_to_db=true)
        params = setup_params(params)
        self.model_class = ::Mixpanel::EventProperty
        
        property_names = []
        if params[:name]
          if params[:name].is_a?(Array)
            property_names += params[:name]
          else
            property_names << params[:name]
          end
        end
        
        property_data = []
        
        request_params = self.select_params(params, [:event, :type, :unit, 
            :interval, :bucket])
        request_params[:resource] = get_method_url('events_properties', 'values')
        
        property_names.each do |property_name|
          request_params[:name] = property_name
          data = send_request(request_params)
          
          property_data << {:target_id => property_name, 
            :request_url => current_url, :content => data}
        end
        
        if save_to_db && !property_data.blank?
          self.model_class.transaction do
            # Get existing key in DB.
            target_ids = get_target_ids(params)
            
            property_data.each do |p_data|
              next if p_data[:content].blank?
              
              attrs = {
                :event_name => params[:event],
                :request_url => p_data[:request_url]
              }
              
              self.insert_or_update(params, target_ids, 
                  p_data[:target_id], p_data[:content].to_json, attrs)
            end
          end
        end
        
        return property_data
      end
    end
  end
end
