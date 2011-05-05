module Fetcher
  module Zendesk
    module Post
      include Fetcher::Zendesk::Base

      attr_accessor :content_keys, :entrys

      def load_entry_ids(credential)
        zendesk_entry = ::Zendesk::Entry
        @entrys = zendesk_entry.where(:credential => extract_credential(credential))
      end

      def fetch_post(credential)
        load_entry_ids(credential)
        ::Zendesk::Entry.transaction do
          @entrys.each do |f|
            f_id = f.target_id
            page_number = 1
            request_url =  ZENDESK_CONFIG["base_url"].gsub(/\[SUBDOMAIN\]/, credential[:subdomain]) + ZENDESK_CONFIG["apis"]["entries"] + "/" + f_id.to_s + ZENDESK_CONFIG["apis"]["posts"]  + "." +  ZENDESK_CONFIG["format"]
            request_url_pagination = request_url + "?page=#{page_number}"
            response = create_request(credential, request_url_pagination)
            logger.info "Created request url: #{request_url}"
            logger.info response.get.to_s
            @content_keys = extract_content_post_keys(response.get)
            format_param = ZENDESK_CONFIG["format"].to_s
            request_url_param = request_url_pagination.to_s
            entry_id = f_id
            begin
              save_post_data(@content_keys, request_url_param, format_param, credential, entry_id, f_id)
            rescue Exception => e
              #TODO send email
              puts e
              puts e.backtrace
            end
            logger.info "Updated data"
            doc = Nokogiri::XML(response.get)
            items_count = doc.xpath("/posts/@count").text
            while items_count == '100' #get next page for pagination
              page_number += 1
              request_url_pagination = request_url + "?page=#{page_number}"
              puts request_url_pagination
              response = create_request(credential, request_url_pagination)
              logger.info "Created request url: #{request_url}"
              logger.info response.get.to_s
              @content_keys = extract_content_post_keys(response.get)
              format_param = ZENDESK_CONFIG["format"].to_s
              request_url_param = request_url_pagination.to_s
              entry_id = f_id
              doc = Nokogiri::XML(response.get)
              items_count = doc.xpath("/posts/@count").text
              begin
                save_post_data(@content_keys, request_url_param, format_param, credential, entry_id, f_id)
              rescue Exception => e
                #TODO send email
                puts e
                puts e.backtrace
              end
              logger.info "Updated data"
            end
          end
        end
      end

      #save data to database after checking for existing record
      def save_post_data(content_keys, request_url_param, format_param, credential, entry_id, parent_id)
        content_keys.each do |content_key|
          data = content_key.values[0]
          extracted_key = content_key.keys[0].to_s
          zendesk_user =  ::Zendesk::Post.find_or_initialize_by_target_id(extracted_key)
          zendesk_user.update_attributes({:request_url => request_url_param, :content => data, :format => format_param, :credential => extract_credential(credential), :target_id => extracted_key, :entry_id => parent_id})
        end
      end

      def extract_content_post_keys(response)
        doc = Document.new response
        extracted_keys = Array.new
        for i in 1..doc.root.elements.size do
          key_value_pair = {doc.root.elements[i].elements["id"].text.to_i => doc.root.elements[i].to_s}
          extracted_keys[i-1] = key_value_pair
        end
        extracted_keys
      end
    end
  end
end

