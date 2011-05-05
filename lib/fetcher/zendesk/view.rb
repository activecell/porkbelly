module Fetcher
  module Zendesk
    module View
      include Fetcher::Zendesk::Base

      attr_accessor :content_keys
      def fetch_view(credential)
        request_url =  ZENDESK_CONFIG["base_url"].gsub(/\[SUBDOMAIN\]/, credential[:subdomain]) + ZENDESK_CONFIG["apis"]["views"] + "." + ZENDESK_CONFIG["format"]
        response = create_request(credential, request_url)
        logger.info "Created request url: #{request_url}"
        logger.info response.get.to_s
        @content_keys = extract_content_view_keys(response.get)
        format_param = ZENDESK_CONFIG["format"].to_s
        request_url_param = request_url.to_s
        begin
          save_view_data(@content_keys, request_url_param, format_param, credential)
        rescue Exception => e
          #TODO send email
          puts e
        end
        logger.info "Updated data"
      end

      #save data to database after checking for existing record
      def save_view_data(content_keys, request_url_param, format_param, credential)
        content_keys.each do |content_key|
          data = content_key.values[0].keys[0]
          extracted_key = content_key.keys[0]
          per_page = content_key.values[0].values[0]
          zendesk_view =  ::Zendesk::View.find_or_initialize_by_target_id(extracted_key)
          logger.info zendesk_view.inspect
          zendesk_view.update_attributes({:request_url => request_url_param, :content => data, :format => format_param, :credential => extract_credential(credential), :target_id => extracted_key, :per_page => per_page})
        end
      end

      def extract_content_view_keys(response)
        doc = Document.new response
        extracted_keys = Array.new
        for i in 1..doc.root.elements.size do
          per_page = doc.root.elements[i].elements["per-page"].text.to_i
          key_value_pair = {doc.root.elements[i].elements["id"].text.to_i => {doc.root.elements[i].to_s => per_page}}
          extracted_keys[i-1] = key_value_pair
        end
        extracted_keys
      end
    end
  end
end

