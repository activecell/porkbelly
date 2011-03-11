module Fetcher
  module Mixpanel
    # FunnelProperty module contains methods to interact with 
    # the API endpoint http://mixpanel.com/api/2.0/funnels/properties of Mixpanel.
    module FunnelProperty
      include Fetcher::Mixpanel::Base    
      
      # List of supported methods in this module.
      @@funnel_property_support_methods = [:fetch_all_funnel_properties, :fetch_funnel_property_names]
      
      # Get unique, total, or average data for a funnel property.
      # == API reference:
      #   http://mixpanel.com/api/docs/guides/api/v2#funnel-properties-default
      # == Parameters:
      #   + params: hash of parameters for the request.
      #       - params[:name]: single or array of funnel properties to fetch. If no properties is specified,
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
      #   An array of hash object parsed from the returned data of Mixpanel service.
      def fetch_all_funnel_properties(params={}, save_to_db=true)
        params = setup_params(params)
        self.model_class = ::Mixpanel::FunnelProperty

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
        
        request_params = self.select_params(params, [:funnel, :unit, :interval, :limit])
        request_params[:resource] = get_method_url('funnels_properties')
          
        # Fetch data for each funnel properties.
        property_names.each do |property_name|        
          request_params[:name] = property_name
          data = send_request(request_params)
          property_data << {
            :target_id => property_name, 
            :request_url => current_url,
            :content => data
          }
        end
        
        # Save to DB?
        if save_to_db && !property_data.blank?
          self.model_class.transaction do
            # Get existing key in DB.
            target_ids = get_target_ids(params)
            
            property_data.each do |p_data|
              next if p_data[:content].blank?
              
              attrs = {
                :funnel_name => params[:funnel],
                :request_url => p_data[:request_url]
              }
              
              self.insert_or_update(params, target_ids, p_data[:target_id], 
                p_data[:content].to_json, attrs)
            end
          end
        end
        
        return property_data
      end
      
      # Get the top properties for a single funnel or array of funnels.
      # == API reference:
      #   http://mixpanel.com/api/docs/guides/api/v2#funnel-properties-names
      # == Parameters:
      #   + params: hash of parameters for the request.
      #       - params[:funnel]: single or array of funnels' names.
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
        request_params = self.select_params(params, [:unit, :interval, :limit])
        request_params[:resource] = get_method_url('funnels_properties', 'names')
        
        funnel_names.each do |funnel_name|
          request_params[:funnel] = funnel_name
          data = send_request(request_params)
          property_data << {
            :target_id => funnel_name, 
            :request_url => current_url, 
            :content => data
          }
        end
          
        if save_to_db && !property_data.blank?
          self.model_class.transaction do
            # Get existing keys from DB.
            target_ids = get_target_ids(params)
            
            property_data.each do |p_data|
              next if p_data[:content].blank?
              
              attrs = {
                :funnel_name => params[:funnel],
                :request_url => p_data[:request_url]
              }
              
              self.insert_or_update(params, target_ids, p_data[:target_id], 
                p_data[:content].to_json, attrs)
            end
          end
        end
        
        return property_data
      end
    end
  end
end
