module Fetcher
  module Mixpanel
    module Funnel
      include Fetcher::Mixpanel::Base
      @@funnel_support_methods = [:fetch_all_funnels, :fetch_funnel_dates, :fetch_funnel_names]
      
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
        data = client.request do
          resource method_url #'funnels'
          funnel   funnel_names.to_s
          unit     params[:unit]
          interval params[:interval]
        end    
        
        if save_to_db && !data.blank?
          self.model_class.transaction do
            # Detect data were changed
            target_ids = nil
            if params[:detect_changes]
              target_ids = self.existence_keys(self.credential[:api_key])
            end
            
            data.keys.each do |funnel_name|
              should_save = false # Flag to save the data to DB or not.
              should_update = false # Flag to update the record or not.
              
              # Detect data is empty or not
              is_empty = (data[funnel_name].blank?)
              json_data = {funnel_name => data[funnel_name]}.to_json
              
              if !is_empty && params[:detect_changes] && !target_ids.blank?
                if target_ids.include?(funnel_name)
                  # Detect data were changed
                  should_save = check_changes(json_data, currrent_url, funnel_name)
                  should_update = true
                else
                  should_save = true
                end
              elsif !is_empty
                should_save = true
              end
              
              if should_save && should_update && params[:update]
                  logger.info "===> Update Mixpanel funnel '#{funnel_name}'..."
                  self.model_class.update_all(
                    { :content => json_data, 
                      :format => FORMATS[:json],
                      :request_url => currrent_url
                    },
                    ["target_id = ? AND credential = ?", funnel_name, credential[:api_key]]
                  )
              elsif should_save
                logger.info "===> Insert new Mixpanel funnel '#{funnel_name}' ..." 
                record = self.model_class.create!({
                  :content => json_data, 
                  :target_id => funnel_name,
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
      
      # Get the names of the funnels you are tracking. 
      def fetch_funnel_names(params={}, save_to_db=true)
        params = setup_params(params)
        self.model_class = ::Mixpanel::Funnel
        
        # The 'unit' can only be 'week'. 
        # Reference: http://mixpanel.com/api/docs/guides/api/v2#funnels-names
        params[:unit] = 'week'
        
        method_url = get_method_url('funnels', 'names')
        data = client.request do
          resource  method_url #'funnels/names'
          unit      params[:unit]
          interval  params[:interval]
        end
          
        if save_to_db && !data.blank?
          # Get existing key in DB.
          target_ids = nil
          if params[:detect_changes]
            target_ids = self.existence_keys(self.credential[:api_key])
          end
            
          self.model_class.transaction do
            data.each do |funnel_name|
              should_save = false # Flag to save the data to DB or not.
              
              if params[:detect_changes] && !target_ids.blank?
                # Detect data were changed
                should_save = !target_ids.include?(funnel_name)
              elsif !is_empty
                should_save = true
              end
              
              if should_save
                logger.info "===> Insert data of funnels/names ..." 
                record = self.model_class.create!({
                  :content => json_data, 
                  :target_id => funnel_name,
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
      
      # Get the dates for which a set of funnels have data.
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
        data = client.request do
          resource  method_url #'funnels/dates'
          funnel    funnel_names.to_s
          unit      params[:unit]
          limit     params[:limit]
        end
                
        if save_to_db && !data.blank?
          self.model_class.transaction do
            # Get existing key in DB.
            target_ids = nil
            if params[:detect_changes]
              target_ids = self.existence_keys(self.credential[:api_key])
            end
            
            data.keys.each do |funnel_name|
              # Detect data is empty or not
              is_empty = (data[funnel_name].blank?)
              json_data = {funnel_name => data[funnel_name]}.to_json
              
              should_save = false
              should_update = false
              
              if !is_empty && params[:detect_changes] && !target_ids.blank?
                if target_ids.include? funnel_name
                  # Detect data were changed
                  should_save = check_changes(json_data, currrent_url, funnel_name)
                  should_update = true
                else
                  should_save = true
                end
              elsif !is_empty
                should_save = true
              end
              
              if should_save && should_update && params[:update]
                logger.info "===> Update Mixpanel funnels/dates  '#{funnel_name}'..."
                self.model_class.update_all(
                  { :content => json_data, 
                    :format => FORMATS[:json],
                    :request_url => currrent_url
                  },
                  ["target_id = ? AND credential = ?", funnel_name, credential[:api_key]]
                )
              elsif should_save
                logger.info "===> Insert new Mixpanel funnels/dates '#{funnel_name}'..." 
                record = self.model_class.create!({
                  :content => json_data, 
                  :target_id => funnel_name,
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
    end
  end
end
