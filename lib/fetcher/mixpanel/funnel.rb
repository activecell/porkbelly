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
        
        data = client.request do
          resource 'funnels'
          funnel   funnel_names.to_s
          unit     params[:unit]
          interval params[:interval]
        end    
        
        if save_to_db && !data.blank?
          self.model_class.transaction do
            data.keys.each do |funnel_name|
              should_save = false # Flag to save the data to DB or not.
              
              # Detect data is empty or not
              is_empty = (data[funnel_name].blank?)
              json_data = {funnel_name => data[funnel_name]}.to_json
              
              if !is_empty && params[:detect_changes]
                # Detect data were changed
                should_save = check_changes(json_data, currrent_url, funnel_name)
              elsif !is_empty
                should_save = true
              end
              
              if should_save
                logger.info "===> Insert data of funnels ..." 
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
        
        data = client.request do
          resource  'funnels/names'
          unit      params[:unit]
          interval  params[:interval]
        end
          
        if save_to_db && !data.blank?
          self.model_class.transaction do
            data.each do |funnel_name|
              should_save = false # Flag to save the data to DB or not.
              
              if params[:detect_changes]
                # Detect data were changed
                should_save = check_changes(json_data, currrent_url, funnel_name)
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
        
        data = client.request do
          resource  'funnels/dates'
          funnel    funnel_names.to_s
          unit      params[:unit]
          limit     params[:limit]
        end
                
        if save_to_db && !data.blank?
          self.model_class.transaction do
            data.keys.each do |funnel_name|
              # Detect data is empty or not
              is_empty = (data[funnel_name].blank?)
              json_data = {funnel_name => data[funnel_name]}.to_json
              
              if !is_empty && params[:detect_changes]
                # Detect data were changed
                should_save = check_changes(json_data, currrent_url, funnel_name)
              elsif !is_empty
                should_save = true
              end
              
              if should_save
                logger.info "===> Insert data of funnels/dates ..." 
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