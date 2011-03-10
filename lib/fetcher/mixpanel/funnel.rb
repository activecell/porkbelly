module Fetcher
  module Mixpanel
    # Funnel module contains methods to interact with 
    # the API endpoint http://mixpanel.com/api/2.0/funnels of Mixpanel
    module Funnel
      include Fetcher::Mixpanel::Base
      
      # List of supported methods in this module.
      @@funnel_support_methods = [:fetch_all_funnels, :fetch_funnel_dates, :fetch_funnel_names]
      
      # Get data for a set of funnels. 
      # == API reference:
      #   http://mixpanel.com/api/docs/guides/api/v2#funnels-default
      # == Parameters:
      #   + params: hash of parameters for the request.
      #       - params[:funnel]: single or array of funnels to fetch. If no funnel is specified.
      #           The method will automatically get all funnels (within a time interval)
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
      def fetch_all_funnels(params={}, save_to_db=true)
        params = setup_params(params)
        self.model_class = ::Mixpanel::Funnel
        
        funnel_names = []
        if params[:funnel]
          if params[:funnel].is_a?(Array)
            funnel_names += params[:funnel]
          else
            funnel_names << params[:funnel]
          end
        else
          # Get names of funnels.        
          funnel_names = self.fetch_funnel_names(params, false)
        end
        
        method_url = get_method_url('funnels')
        request_params = self.select_params(params, [:unit, :interval])
        request_params[:resource] = method_url
        request_params[:funnel] = funnel_names.to_json
        
        data = send_request(request_params)
                  
        if save_to_db && !data.blank?
          self.model_class.transaction do
            # Detect data were changed
            target_ids = get_target_ids(params)
            
            data.keys.each do |funnel_name|
              next if data[funnel_name].blank?
              
              json_data = {funnel_name => data[funnel_name]}.to_json              
              self.insert_or_update(params, target_ids, funnel_name, json_data)
            end
          end
        end
        return data
      end
      
      # Get the names of the funnels you are tracking.
      # == API reference:
      #   http://mixpanel.com/api/docs/guides/api/v2#funnels-names
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
      #   An array containing names of funnels.
      def fetch_funnel_names(params={}, save_to_db=true)
        params = setup_params(params)
        self.model_class = ::Mixpanel::Funnel
        
        # The 'unit' can only be 'week'. 
        # Reference: http://mixpanel.com/api/docs/guides/api/v2#funnels-names
        params[:unit] = 'week'
        params[:update] = false
        
        method_url = get_method_url('funnels', 'names')
        request_params = self.select_params(params, [:unit, :interval])
        request_params[:resource] = method_url
        
        data = send_request(request_params)

        if save_to_db && !data.blank?
          # Get existing key in DB.
          target_ids = get_target_ids(params)
            
          self.model_class.transaction do
            data.each do |funnel_name|
              self.insert_or_update(params, target_ids, funnel_name, funnel_name)
            end
          end
        end
        
        return data
      end
      
      # Get the dates for which a set of funnels have data.
      # == API reference:
      #   http://mixpanel.com/api/docs/guides/api/v2#funnels-dates
      # == Parameters:
      #   + params: hash of parameters for the request.
      #       - params[:funnel]: single or array of funnels to fetch.
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
      def fetch_funnel_dates(params={}, save_to_db=true)
        params = setup_params(params)
        self.model_class = ::Mixpanel::Funnel

        funnel_names = []
        if params[:funnel]
          if params[:funnel].is_a?(Array)
            funnel_names += params[:funnel]
          else
            funnel_names << params[:funnel]
          end
        end
        
        method_url = get_method_url('funnels', 'dates')
        request_params = self.select_params(params, [:unit, :limit])
        request_params[:resource] = method_url
        request_params[:funnel] = funnel_names.to_json
        
        data = send_request(request_params)
                
        if save_to_db && !data.blank?
          self.model_class.transaction do
            # Get existing key in DB.
            target_ids = get_target_ids(params)
            
            data.keys.each do |funnel_name|
            
              next if data[funnel_name].blank?
              json_data = {funnel_name => data[funnel_name]}.to_json
              
              self.insert_or_update(params, target_ids, funnel_name, json_data)
            end
          end
        end
        return data
      end
    end
  end
end
