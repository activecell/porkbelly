module Fetcher
  module Salesforce
    module ObjectMetadata
      include Fetcher::Salesforce::Base
      
      # Fetch object metadata
      # == Parameters
      #   + session_id: Session ID
      def fetch_object_metadata(session_id)
        # Setup params.
        setup_params_logic = lambda do |last_request, params|
          # Do nothing.
        end
        
        # Parse the response.
        response_parse_logic = lambda do |response|        
          
        end
      end
    end
  end
end
