module Fetcher
  module Zendesk
    module Entry
      include Fetcher::Zendesk::Base

      attr_accessor :content_keys, :forums

      def load_forum_ids
        zendesk_forum = ::Zendesk::Forum
        @forums = zendesk_forum.find(:all)
      end

      def fetch_entry(credential)
        load_forum_ids
        @forums.each do |f|
          f_id = f.target_id
          request_url =  ZENDESK_CONFIG["base_url"].gsub(/\[SUBDOMAIN\]/, credential[:subdomain]) + ZENDESK_CONFIG["apis"]["forums"] + "/" + f_id.to_s + ZENDESK_CONFIG["apis"]["entries"] + "." + ZENDESK_CONFIG["format"]
          response = create_request(credential, request_url)
          logger.info response.get.to_s
          @content_keys = extract_content_keys(response.get)
          format_param = ZENDESK_CONFIG["format"].to_s
          request_url_param = request_url.to_s
          forum_id = f_id
          save_entry_data(@content_keys, request_url_param, format_param, credential, forum_id)
        end
      end

      #save data to database after checking for existing record
      def save_entry_data(content_keys, request_url_param, format_param, credential, forum_id)
        content_keys.each do |content_key|
          data = content_key.values[0]
          extracted_key = content_key.keys[0]
          zendesk_entry =  ::Zendesk::Entry.find_or_initialize_by_target_id(extracted_key)
          logger.info zendesk_entry.inspect
          zendesk_entry.update_attributes({:request_url => request_url_param, :content => data, :format => format_param, :credential => credential, :target_id => extracted_key, :forum_id => forum_id})
        end
      end

    end
  end
end
