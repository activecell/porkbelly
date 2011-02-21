module Fetchers
  module Mixpanel
    class FunnelPropertyFetcher
      include Fetchers::Mixpanel::Base     
      @@support_methods = [:all_properties, :names]
      
      def initialize(credential)
        new_client(credential)
        self.model_class = MP::FunnelProperty
      end
      
      # Get unique, total, or average data for a funnel property.
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
          json_property_names = self.names(params, false)
          property_names = JSON.parse(json_property_names).keys
        end        
        
        property_data = []
        
        property_names.each do |proper_name|
          data = client.request do
            resource 'funnels/properties'
            funnel    params[:funnel]
            name      proper_name
            unit      params[:unit]
            interval  params[:interval]
            limit     params[:limit]
          end
          
          property_data << {:request_url => currrent_url, :content => data}
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
                should_save = check_changes(json_data, p_data[:request_url])
              elsif !is_empty
                should_save = true
              end
              
              if should_save
                logger.info "===> Insert data of funnels/properties ..." 
                record = self.model_class.create!({
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
      
      # Get the top properties for a single funnel or array of funnels. 
      def names(params={}, save_to_db=true)
        params = setup_params(params)
        
        funnel_names = []
        if params[:funnel]
          if params[:funnel].is_a?(Array)
            funnel_names += params[:funnel]
          else
            funnel_names << params[:funnel]
          end
        end
        
        property_data = []
        
        funnel_names.each do |proper_name|
          data = client.request do
            resource  'funnels/properties/names'
            funnel    params[:funnel]
            unit      params[:unit]
            interval  params[:interval]
            limit     params[:limit]
          end          
          property_data << {:request_url => currrent_url, :content => data}
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
                should_save = check_changes(json_data, p_data[:request_url])
              elsif !is_empty
                should_save = true
              end
              
              if should_save
                logger.info "===> Insert data of funnels/properties/names ..."            
                record = self.model_class.create!({
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
    end
  end
end
