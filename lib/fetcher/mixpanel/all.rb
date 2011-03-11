module Fetcher
  module Mixpanel    
    class All
      include Fetcher::Mixpanel::Event
      include Fetcher::Mixpanel::EventProperty
      include Fetcher::Mixpanel::Funnel
      include Fetcher::Mixpanel::FunnelProperty      
      
      def initialize(credential)
        tmp_credential = normalize_credential!(credential)        
        super(tmp_credential)
      end
      
      # fetch data for the given credential
      def fetch_data(method="fetch_all", params={})
        begin
          data = nil
          
          if supported_methods.include?(method)
            if self.single_fetch?
              new_client(self.credential)
              data = send(method, params)
            else
              # Multiple fetch.
              self.credential.each do |creden|
                begin
                  new_client(creden)
                  data = send(method, params)
                rescue Exception => exc
                  logger.error "Error when run method '#{method}' with params='#{params}'"
                  notify_exception(SITE, exc)
                end
              end
            end
          else
            raise ArgumentError, "Invalid method. Supported methods are: #{supported_methods}" 
          end
          return data  
        rescue Exception => exception
          logger.error(exception)
          notify_exception(SITE, exception)
          #raise exception
        end
      end
      
      def self.supported_methods
        @@supported_method ||= nil
        
        return @@supported_method if @@supported_method
        @@supported_method = @@event_supported_methods + 
          @@event_property_supported_methods +
          @@funnel_support_methods +
          @@funnel_property_support_methods
          
        @@supported_method << 'fetch_all'        
      end
      
      def supported_methods
        self.class.supported_methods
      end
      
      private
      def fetch_all(params={})
        # Fetcher all event data (events and event properties).
        events = fetch_all_events(params)
        if (!events.blank? && 
            !events['data'].blank? && 
            !events['data']['values'].blank?)
            
          events['data']['values'].keys.each do |event_name|
            logger.info "===> Fetching properties for event #{event_name} ...."
            
            params[:event] = event_name          
            properties = fetch_all_properties(params)
            
            logger.info "===> Finished fetching properties for event #{event_name}"        
          end
        end
        
        # Fecth all funnels data (funnel and funnel properties).
        funnels = fetch_all_funnels(params)
        if(!funnels.blank?)
          funnels.keys.each do |funnel_name|
            logger.info "===> Fetching properties for funnel #{funnel_name} ...."
            
            params[:funnel] = funnel_name
            funnel_properties = fetch_all_funnel_properties(params)
            
            logger.info "===> Finished fetching properties for funnel #{funnel_name}"      
          end
        end
      end
    end
  end
end
