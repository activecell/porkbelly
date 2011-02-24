module Fetcher
  module Zendesk
    module Group
      include Fetcher::Zendesk::Base

      attr_accessor :content_keys
      def fetch_group(credential)
        request_url =  ZENDESK_CONFIG["base_url"].gsub(/\[SUBDOMAIN\]/, credential[:subdomain]) + ZENDESK_CONFIG["apis"]["groups"] + "." + ZENDESK_CONFIG["format"]
        response = create_request(credential, request_url)
        logger.info response.get.to_s
        @content_keys = extract_content_keys(response.get)
        format_param = ZENDESK_CONFIG["format"].to_s 
        request_url_param = request_url.to_s
        save_group_data(@content_keys, request_url_param, format_param, credential)
      end

      #save data to database after checking for existing record
      def save_group_data(content_keys, request_url_param, format_param, credential)
        zendesk_group =  ::Zendesk::Group
        content_keys.each do |content_key|
          data = content_key.values[0]
          extracted_key = content_key.keys[0]
          #if !check_existence_record(zendesk_group, data)
          #  puts "GROUP data not duplicated"
            zendesk_group.create(:request_url => request_url_param, :content => data, :format => format_param, :credential => credential, :target_id => extracted_key)
          #else puts "GROUP data DUPLICATED"
          #end
        end
      end

    end
  end
end