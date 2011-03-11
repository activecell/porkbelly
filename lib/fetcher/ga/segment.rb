module Fetcher
  module GA
    module Segment
      include Fetcher::GA::Base

      def fetch_segment(credential)
        request_url =  GA_CONFIG["base_url"] + GA_CONFIG["apis"]["segments"]
        response = create_request(request_url)
        content = response.to_s
        begin
          save_segment(content, credential, request_url)
        rescue 
          raise "Data is not fully propered or adequate"
        end
      end

      def save_segment(content, credential, request_url)
        ga_segment =  ::GA::Segment
        logger.info ga_segment.inspect
        ga_segment.create(:content => content,
                          :credential => credential.inspect,
                          :request_url => request_url,
                          :format => "xml")
      end

    end
  end
end

