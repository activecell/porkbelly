module Fetcher
  module Mixpanel
    module EventProperty
      include Fetcher::Mixpanel::Base
      
      @@event_property_supported_methods = [
        :fetch_all_properties, :fetch_top_properties, :fetch_top_property_values]
      
      # Get total, unique, or average data from a single or an array event property.
      # Parameters:
      #   - params: parameters for the request.
      #   - save_to_db: determine to save the responded data to DB or not.
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
        
        property_names.each do |proper_name|
          data = client.request do
            resource 'events/properties'
            event    params[:event]
            name     proper_name
            values   params[:values]
            type     params[:type]
            unit     params[:unit]
            interval params[:interval]
            format   params[:format]
            bucket   params[:bucket]
          end
          
          property_data << {
            :target_id => proper_name, 
            :request_url => currrent_url, 
            :content => data
          }
        end
        
        if save_to_db
          self.model_class.transaction do            
            property_data.each do |p_data|
              should_save = false # Flag to save the data to DB or not.
              
              # Detect data is empty or not
              is_empty = (p_data[:content].blank? || p_data[:content][RESPONSE_KEYS[:legend_size]].to_i <= 0)
              
              json_data = p_data[:content].to_json
              
              if !is_empty && params[:detect_changes]
                # Detect data were changed
                should_save = check_changes(json_data, p_data[:request_url], p_data[:target_id])
              elsif !is_empty
                should_save = true
              end
              
              if should_save
                logger.info "===> Insert data of events/properties ..."        
                record = self.model_class.create!({
                  :content => json_data, 
                  :target_id => p_data[:target_id],
                  :format => FORMATS[:json],
                  :credential => credential[:api_key],
                  :request_url => p_data[:request_url]
                })
              end
            end
          end
        end
        
        return property_data
      end
      
      # Get the top properties for an event.
      # Parameters:
      #   - params: parameters for the request.
      #   - save_to_db: determine to save the responded data to DB or not.
      def fetch_top_properties(params={}, save_to_db=true)
        params = setup_params(params)
        self.model_class = ::Mixpanel::EventProperty
        
        data = client.request do
          resource 'events/properties/top'
          event    params[:event]
          type     params[:type]
          unit     params[:unit]
          interval params[:interval]
          limit    params[:limit]       
          bucket   params[:bucket]
        end
        
        if save_to_db
          self.model_class.transaction do   
            data.keys.each do |property_name|
              should_save = false # Flag to save the data to DB or not.
              
              json_data = {name => data[property_name]}.to_json
              
              if params[:detect_changes]
                # Detect data were changed
                should_save = check_changes(json_data, currrent_url, property_name)
              elsif !is_empty
                should_save = true
              end
              
              if should_save
                logger.info "===> Insert data of events/properties/top ..." 
                record = self.model_class.create!({
                  :content => json_data, 
                  :target_id => property_name,
                  :format => FORMATS[:json],
                  :credential => credential[:api_key],
                  :request_url => currrent_url
                })
              end
            end
          end
        end
        return data
      end
      
      # Get the top values for a single event property.
      # Parameters:
      #   - params: parameters for the request.
      #   - save_to_db: determine to save the responded data to DB or not.
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
        
        property_names.each do |property_name|
          data = client.request do
            resource 'events/properties/values'
            event    params[:event]
            name     property_name
            type     params[:type]
            unit     params[:unit]
            interval params[:interval]
            bucket   params[:bucket]
          end
          
          property_data << {:target_id => property_name, 
            :request_url => currrent_url, :content => data}
        end
        
        if save_to_db
          self.model_class.transaction do            
            property_data.each do |p_data|
              should_save = false # Flag to save the data to DB or not.
              
              # Detect data is empty or not
              is_empty = (p_data[:content].blank?)
              
              json_data = p_data[:content].to_json
              
              if !is_empty && params[:detect_changes]
                # Detect data were changed
                should_save = check_changes(json_data, p_data[:request_url], p_data[:target_id])
              elsif !is_empty
                should_save = true
              end
              
              if should_save
                logger.info "===> Insert data of events/properties/values ..." 
                record = self.model_class.create!({
                  :content => json_data, 
                  :target_id => p_data[:target_id],
                  :format => FORMATS[:json],
                  :credential => credential[:api_key],
                  :request_url => p_data[:request_url]
                })
              end
            end
          end
        end
        
        return property_data
      end
    end
  end
end
