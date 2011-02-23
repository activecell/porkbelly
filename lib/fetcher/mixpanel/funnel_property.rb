module Fetcher
  module Mixpanel
    module FunnelProperty
      include Fetcher::Mixpanel::Base     
      @@funnel_property_support_methods = [:fetch_all_funnel_properties, :fetch_funnel_property_names]
      
      # Get unique, total, or average data for a funnel property.
      def fetch_all_funnel_properties(params={}, save_to_db=true)
        params = setup_params(params)
        self.model_class = ::Mixpanel::FunnelProperty
        funnel_name = params[:funnel]
        
        property_names = []
        if params[:name]
          if params[:name].is_a?(Array)
            property_names += params[:name]
          else
            property_names << params[:name]
          end
        else
          # Get names of properties.        
          tmp_data = self.fetch_funnel_property_names(params, false)
          if(!tmp_data.blank?)
            tmp_data.each do |property|
              property_names += property[:content].keys
            end
          end
        end        
        
        property_data = []
        
        method_url = get_method_url('funnels_properties')
        property_names.each do |property_name|
          data = client.request do
            resource  method_url #'funnels/properties'
            funnel    funnel_name
            name      property_name
            unit      params[:unit]
            interval  params[:interval]
            limit     params[:limit]
          end
          
          property_data << {
            :target_id => property_name, 
            :request_url => currrent_url,
            :content => data
          }
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
                should_save = check_changes(json_data, p_data[:request_url],  p_data[:target_id])
              elsif !is_empty
                should_save = true
              end
              
              if should_save
                logger.info "===> Insert data of funnels/properties ..." 
                record = self.model_class.create!({
                  :content => json_data, 
                  :target_id =>  p_data[:target_id],
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
      
      # Get the top properties for a single funnel or array of funnels. 
      def fetch_funnel_property_names(params={}, save_to_db=true)
        params = setup_params(params)
        self.model_class = ::Mixpanel::FunnelProperty

        funnel_names = []
        if params[:funnel]
          if params[:funnel].is_a?(Array)
            funnel_names += params[:funnel]
          else
            funnel_names << params[:funnel]
          end
        end
        
        property_data = []
        
        method_url = get_method_url('funnels_properties', 'names')
        funnel_names.each do |funnel_name|
          data = client.request do
            resource  method_url #'funnels/properties/names'
            funnel    funnel_name
            unit      params[:unit]
            interval  params[:interval]
            limit     params[:limit]
          end          
          property_data << {
            :target_id => funnel_name, 
            :request_url => currrent_url, 
            :content => data
          }
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
                logger.info "===> Insert data of funnels/properties/names ..."            
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
