module Fetcher
  module Zendesk
    module Organization
      include Fetcher::Zendesk::Base

      attr_accessor :content_keys
      def fetch_client(credential)
        request_url =  ZENDESK_CONFIG["base_url"].gsub(/\[SUBDOMAIN\]/, credential[:subdomain]) + ZENDESK_CONFIG["apis"]["organizations"] + "." + ZENDESK_CONFIG["format"]
        response = create_request(credential, request_url)
        logger.info response.get.to_s
        @content_keys = extract_content_keys(response.get)
        format = ZENDESK_CONFIG["format"]
        save_data(@content_keys, request_url, credential, format)
      end

      #save data to database after checking for existing record
      def save_data(request_url, credential, format, target_id)
        zendesk_organization =  ::Zendesk::Organization
        @content_keys.each do |content_key|
          data = @content_keys[0].values[0]
          extracted_key = @content_keys[0].keys[0]
          if !check_existence_record(zendesk_organization, data)
            zendesk_organization.create(:request_url => request_url, :content => data, :credential => credential.to_s, :format => format, :target_id => extracted_key)
          end
        end
      end

    end
  end
end
