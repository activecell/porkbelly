module Fetchers
  module Mixpanel
    class FunnelFetcher
      include Fetchers::Mixpanel::Base
      @@support_methods = [:all_funnels, :names, :dates]
      
      def initialize(credential)
        new_client(credential)
        self.model_class = MP::Funnel
      end
      
      def all_funnels(params={}, save_to_db=true)
        params = setup_params(params)
        
        funnel_names = []
        if params[:funnel]
          if params[:funnel].is_a?(Array)
            funnel_names += params[:funnel]
          else
            funnel_names << params[:funnel]
          end
        else
          # Get names of funnels.        
          funnel_names = self.names(params, false)
        end
        
        data = client.request do
          resource 'funnels'
          funnel   funnel_names.to_s
          unit     params[:unit]
          interval params[:interval]
        end      
        
        # Format to JSON data.
        json_data = data.to_json       
        
        if save_to_db
          should_save = false # Flag to save the data to DB or not.
          
          # Detect data is empty or not
          is_empty = (data.blank?)
          
          if !is_empty && params[:detect_changes]
            # Detect data were changed
            should_save = check_changes(json_data, currrent_url)
          elsif !is_empty
            should_save = true
          end
          
          if should_save
            logger.info "===> Insert data of funnels ..." 
            record = self.model_class.create!({
              :content => json_data, 
              :format => FORMATS[:json],
              :credential => credential[:api_key],
              :request_url => currrent_url
            })
          end
        end
        return json_data
      end
      
      # Get the names of the funnels you are tracking. 
      def names(params={}, save_to_db=true)
        params = setup_params(params)
        
        # The 'unit' can only be 'week'. 
        # Reference: http://mixpanel.com/api/docs/guides/api/v2#funnels-names
        params[:unit] = 'week'
        
        data = client.request do
          resource  'funnels/names'
          unit      params[:unit]
          interval  params[:interval]
        end
          
        if save_to_db
          # Detect data is empty or not
          is_empty = (data.blank?)          
          # Format to JSON data.
          json_data = data.to_json
          
          if !is_empty && params[:detect_changes]
            # Detect data were changed
            should_save = check_changes(json_data, currrent_url)
          elsif !is_empty
            should_save = true
          end
          
          if should_save
            logger.info "===> Insert data of funnels/names ..." 
            record = self.model_class.create!({
              :content => json_data, 
              :format => FORMATS[:json],
              :credential => credential[:api_key],
              :request_url => currrent_url
            })
          end
        end
        
        return data
      end
      
      # Get the dates for which a set of funnels have data.
      def dates(params={}, save_to_db=true)
        params = setup_params(params)
        
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
        
        # Format to JSON data.
        json_data = data.to_json  
        
        if save_to_db
          # Detect data is empty or not
          is_empty = (data.blank?)
          
          if !is_empty && params[:detect_changes]
            # Detect data were changed
            should_save = check_changes(json_data, currrent_url)
          elsif !is_empty
            should_save = true
          end
          
          if should_save
            logger.info "===> Insert data of funnels/dates ..." 
            record = self.model_class.create!({
              :content => json_data, 
              :format => FORMATS[:json],
              :credential => credential[:api_key],
              :request_url => currrent_url
            })
          end
        end
        
        return data
      end
    end
  end
end
