module Fetcher
  module Zendesk
    module Entry
      include Fetcher::Zendesk::Base

      attr_accessor :content_keys, :forums

      def load_forum_ids(credential)
        zendesk_forum = ::Zendesk::Forum
        @forums = zendesk_forum.where(:credential => extract_credential(credential))
      end

      def fetch_entry(credential)
        load_forum_ids(credential)
        @forums.each do |f|
          f_id = f.target_id
          page_number = 0
          request_url =  ZENDESK_CONFIG["base_url"].gsub(/\[SUBDOMAIN\]/, credential[:subdomain]) + ZENDESK_CONFIG["apis"]["forums"] + "/" + f_id.to_s + ZENDESK_CONFIG["apis"]["entries"] + "." + ZENDESK_CONFIG["format"]
          items_count = '25'
          while items_count == '25' #get next page for pagination
            page_number += 1
            request_url_pagination = request_url + "?page=#{page_number}"
            response = create_request(credential, request_url_pagination)
            logger.info "Created request url: #{request_url}"
            logger.info response.get.to_s
            @content_keys = extract_content_keys(response.get)
            format_param = ZENDESK_CONFIG["format"].to_s
            request_url_param = request_url.to_s
            forum_id = f_id
            doc = Nokogiri::XML(response.get)
            items_count = doc.xpath("/entries/@count").text
            begin
              save_entry_data(@content_keys, request_url_param, format_param, credential, forum_id)
            rescue Exception => e
              #TODO send email
              puts e
              puts e.backtrace
            end
              logger.info "Updated data"
          end
        end
      end

      #save data to database after checking for existing record
      def save_entry_data(content_keys, request_url_param, format_param, credential, forum_id)
        content_keys.each do |content_key|
          data = content_key.values[0]
          extracted_key = content_key.keys[0]
          zendesk_entry =  ::Zendesk::Entry.find_or_initialize_by_target_id(extracted_key)
          logger.info zendesk_entry.inspect
          zendesk_entry.update_attributes({:request_url => request_url_param, :content => data, :format => format_param, :credential => extract_credential(credential), :target_id => extracted_key, :forum_id => forum_id})
        end
      end

    end
  end
end

