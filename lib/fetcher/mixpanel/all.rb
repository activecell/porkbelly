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
      
      def fetch_all
        begin
          if single_fetch?
            logger.info "===> Starting Mixpanel single fetching..."
            
            fetch_single(self.credential)
            
            logger.info "===> Finish Mixpanel single fetching."
          else
            logger.info "===> Starting Mixpanel multiple fetching..."
            
            self.credential.each do |c|
              begin
                fetch_single(c)
              rescue Exception => exc
                logger.error "Error when fetching with credential: #{c}"
                logger.error exc
              end
            end
            
            logger.info "===> Finish Mixpanel multiple fetching."
          end
        rescue Exception => exc
          logger.error exc
          logger.error exc.backtrace
          notify_exception(SITE, exc)          
        end
      end    
      
      def fetch_single(credential)
        new_client(credential)
        params = {}
        
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
    
      def self.supported_methods
        @@supported_method ||= nil
        
        return @@supported_method if @@supported_method
        @@supported_method = @@event_supported_methods + 
          @@event_property_supported_methods +
          @@funnel_support_methods +
          @@funnel_property_support_methods
          
        @@supported_method += ['fetch_all', 'fetch_single']
      end
      
      def supported_methods
        self.class.supported_methods
      end
    end
  end
end
