module Fetchers
  module Mixpanel    
    class MixpanelFetcher
      include Fetchers::Mixpanel::Base   
      
      OPTIONS = [:all, :events, :event_properties, :funnels, :funnel_properties]
      
      # fetch data for the given credential
      def fetch_data(credential, data_type, params={}, method="all_events")
        begin
          data_type = data_type.to_sym
          data = nil
          
          if data_type != :all
            data = send("fetch_#{data_type}", credential, params, method)
          else
            data = send("fetch_all", credential, params)
          end
          #~ case data_type
           #~ when :all
            #~ data = fetch_all(credential, params)
           #~ when :events
            #~ data = fetch_events(credential, params)
           #~ when :event_properties
            #~ data = fetch_event_properties(credential, params)
           #~ when :funnels
            #~ data = fetch_funnels(credential, params)
           #~ when :funnel_properties
            #~ data = fetch_funnel_properties(credential, params)
          #~ end
          
          return data  
        rescue Exception => exception
          notify_exception(SITE, exception)
        end
      end
      
      def fetch_all(credential, params={})
        # Fetcher all event data.
        fetch_events(credential, params)
        fetch_event_properties(credential, params)
        
        # Fecth all funnels data (funnel and funnel properties.
        fetch_funnels(credential, params)
        fetch_funnel_properties(credential, params)
      end
      
      # Valid method names: :all_events, :name, :top, :retention
      def fetch_events(credential, params={}, method_name="all_events")
        logger.info "Fetching events/#{method_name} from Mixpanel..."
        begin
          fetcher = EventFetcher.new(credential)
          
          # Check supported method.
          if !fetcher.is_method_supported?(method_name)
            method_name = :all_events
          end
          
          # Call the method.
          events = fetcher.send(method_name, params)
          return events
        rescue Exception => exception
          notify_exception(SITE, exception)
        end
      end
      
      def fetch_event_properties(credential, params={}, method_name="all_properties")
        logger.info "Fetching event/properties/#{method_name} from Mixpanel..."
        begin
          fetcher = EventPropertyFetcher.new(credential)
          
          # Check supported method.          
          if !fetcher.is_method_supported?(method_name)
            method_name = :all_properties
          end
          
          # Call the method.
          data = fetcher.send(method_name, params)
          return data
        rescue Exception => exception
          notify_exception(SITE, exception)
        end
      end
      
      def fetch_funnels(credential, params={}, method_name="all_funnels")
        logger.info "Fetching funnels/#{method_name} from Mixpanel..."
        begin
          fetcher = FunnelFetcher.new(credential)
          
          # Check supported method.
          if !fetcher.is_method_supported?(method_name)
            method_name = :all_funnels
          end
          
          # Call the method.
          data = fetcher.send(method_name, params)
          
          return data
        rescue Exception => exception
          notify_exception(SITE, exception)
        end
      end
      
      def fetch_funnel_properties(credential, params={}, method_name="all_properties")
        logger.info "Fetching funnel properties/#{method_name} from Mixpanel..."
        begin
          fetcher = FunnelPropertyFetcher.new(credential)
          
          # Check supported method.
          if !fetcher.is_method_supported?(method_name)
            method_name = :all_properties
          end          
          
          # Call the method.
          data = fetcher.send(method_name, params)
          
          return data
        rescue Exception => exception
          notify_exception(SITE, exception)
        end
      end
    end
  end
end
