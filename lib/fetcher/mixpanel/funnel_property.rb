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
        
        if save_to_db && !property_data.blank?
          self.model_class.transaction do
            # Get existing key in DB.
            target_ids = nil
            if params[:detect_changes]
              target_ids = self.existence_keys(self.credential[:api_key])
            end
            
            property_data.each do |p_data|
              should_save = false # Flag to save the data to DB or not.
              should_update = false # Flag to update the record or not.
              
              # Detect data is empty or not
              is_empty = (p_data[:content].blank?)
              
              json_data = p_data[:content].to_json
              
              if !is_empty && params[:detect_changes] && !target_ids.blank?
                if target_ids.include? p_data[:target_id]
                  # Detect data were changed
                  should_save = check_changes(json_data, p_data[:request_url],  p_data[:target_id])
                  should_update = true
                else
                  should_save = true
                end
              elsif !is_empty
                should_save = true
              end
              
              if should_save && should_update && params[:update]
                logger.info "===> Update Mixpanel funnels/properties '#{p_data[:target_id]}'..."
                self.model_class.update_all(
                  { :content => json_data, 
                    :format => FORMATS[:json],
                    :request_url =>  p_data[:request_url]
                  },
                  ["target_id = ? AND credential = ?", p_data[:target_id], credential[:api_key]]
                )
              elsif should_save
                logger.info "===> Insert new Mixpanel funnels/properties ..." 
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
          
        if save_to_db && !property_data.blank?
          self.model_class.transaction do
            # Get existing keys from DB.
            target_ids = nil
            if params[:detect_changes]
              target_ids = self.existence_keys(self.credential[:api_key])
            end
            
            property_data.each do |p_data|
              should_save = false # Flag to save the data to DB or not.
              should_update = false
              
              # Detect data is empty or not
              is_empty = (p_data[:content].blank?)
              
              json_data = p_data[:content].to_json
              
              if !is_empty && params[:detect_changes] & !target_ids.blank?
                if target_ids.include p_data[:target_id]
                  # Detect data were changed
                  should_save = check_changes(json_data, p_data[:request_url], p_data[:target_id])
                  should_update = true
                else
                  should_save = true
                end
              elsif !is_empty
                should_save = true
              end
              
              if should_save && should_update && params[:update]
                logger.info "===> Update Mixpanel funnels/properties/names '#{p_data[:target_id]}'..."
                self.model_class.update_all(
                  { :content => json_data, 
                    :format => FORMATS[:json],
                    :request_url => p_data[:request_url]
                  },
                  ["target_id = ? AND credential = ?", p_data[:target_id], credential[:api_key]]
                )
              elsif should_save
                logger.info "===> Insert new Mixpanel funnels/properties/names ..."            
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
